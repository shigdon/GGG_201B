
## IGG201B - Lab Homework 2
### Shawn Higdon
#### March 2, 2017

=======================================

1. Install Megahit assembler:

        git clone https://github.com/voutcn/megahit.git
        cd megahit
        make -j 4
        
2. Install Quast:

        cd ~/
        git clone https://github.com/ablab/quast.git -b release_4.2
        export PYTHONPATH=$(pwd)/quast/libs/

3. Install Trimmomatic:

        sudo apt-get -y install trimmomatic
        
4. Install khmer:

        pip install khmer==2.0
      
5. Make a work directory and download the E.coli data set within that directory:

        mkdir ~/work
        cd ~/work

        curl -O -L https://s3.amazonaws.com/public.ged.msu.edu/ecoli_ref-5m.fastq.gz

6. Download TruSeq3-PE-adapters:

        wget https://anonscm.debian.org/cgit/debian-med/trimmomatic.git/plain/adapters/TruSeq3-PE.fa
        
7. Look at the ecoli fastq file to see if it is interleaved:

        gunzip -c ecoli_ref-5m.fastq.gz | head
        @EAS20_8_6_1_2_768/1
        CAGCACAGAGGATATCGCTGTTACANNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
        +
        HGHIHHHGHECHHHHHHHGGHHHHH###########################################################################
        @EAS20_8_6_1_2_768/2
        NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNGNNNNNNNNNNNNNNNNNNNNNNTNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
        +
        ####################################################################################################
        @EAS20_8_6_1_2_1700/1
        CTTGGTGCGGAACTGAAAAGTGGTANNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

8. Split the paired end reads from the interleaved fastq file using khmer:

        gunzip -c ecoli_ref-5m.fastq.gz | split-paired-reads.py -1 top.R1.fq -2 top.R2.fq
        Output...
        ...
        //
        ...
        DONE; split 5000000 sequences (2500000 left, 2500000 right, 0 orphans)
        /1 reads in top.R1.fq
        /2 reads in top.R2.fq
        
9. Run Trimmomatic on the split reads:

        TrimmomaticPE -threads 4 top.R1.fq top.R2.fq trim-R1.fq orphan-R1.fq trim-R2.fq orphan-R2.fq ILLUMIN
        ACLIP:TruSeq3-PE.fa:2:40:15 LEADING:2 TRAILING:2 SLIDINGWINDOW:4:2 MINLEN:25
        
          _**OUTPUT**_
      
        TrimmomaticPE: Started with arguments: -threads 4 top.R1.fq top.R2.fq trim-R1.fq orphan-R1.fq trim-R2.fq 
        orphan-R2.fq ILLUMINACLIP:TruSeq3-PE.fa:2:40:15 LEADING:2 TRAILING:2 SLIDINGWINDOW:4:2 MINLEN:25 
        Using PrefixPair: 'TACACTCTTTCCCTACACGACGCTCTTCCGATCT' and 'GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT'
        ILLUMINACLIP: Using 1 prefix pairs, 0 forward/reverse sequences, 0 forward only sequences, 
        0 reverse only sequences
        Quality encoding detected as phred33 Input Read Pairs: 2500000 Both Surviving: 2495801 (99.83%) 
        Forward Only Surviving: 3712 (0.15%) Reverse Only Surviving: 461 (0.02%)
        Dropped: 26 (0.00%)
        TrimmomaticPE: Completed successfully


10. Check the trimmed output files:

        ubuntu@ip-172-31-23-122:~/work$ head trim-R1.fq
        @EAS20_8_6_1_3_2012/1
        GAAACAGCGCCAGCCCGCAGTAAAAACCGATGCGACTGAGTGTGCGTTTATTTGTTGCCATTGAGGTTCACCCGTTTCCTGGTCAGCAGAATGACAGCGA
        +
        HHHHHHHHGHHHHHHGHGDHHHEBEDHHH@FFFHAEGHGGACEHFHEGEEHHEEGGHDGAHGE5GGGGG>HFGDEDGEEH@45@57=7:9<DE9E??1@<
        @EAS20_8_6_1_3_725/1
        GAAACATGGGCCAGCTGGTTGTCATTTAATAATGTGAGAATGGTGTCTTCGCCTGCTTCTGGCGCGTACTCCGCCATCACTTCTTCACGACTTAACTTCC
        +
        HHHHHHHHHHHHHHHHHHHHHHHHHHHHDHHFHHIHGHEFHF:GDHHHHHEHGGEGHIHHHEHCGAEGGGGHEHG1CC=CGGGGFGGGBFGGGFGCGGGG
        @EAS20_8_6_1_3_642/1
        AAATCAAAAAACCCGGTCACTTTTTTACAAGGTAACCGGGTAAAAATAATTTTTATTTTTTAACTGTTTTGAGACTCATAGAGATGTCTCAAAACTAAAA
        ubuntu@ip-172-31-23-122:~/work$ head trim-R2.fq
        @EAS20_8_6_1_3_2012/2
        TTTNCTNNNGACNAAGGTCGATATTCTCGGTGTATATCTCTACAAAACCGCCTTTGCCTTTAATGATTTAGGAAAAGCGGCGGCGGTCTCGGTGGTTGTC
        +
        554%55&%%455&54;+86:>EEEEEEEEE>EEEEEEEE:EEEEEE>EEEEEEEEEEEEEE=EEEEEEEE;)?<77@+C@C###################
        @EAS20_8_6_1_3_725/2
        ATGNGTNNNTCGNTGGCGATCCTGACCATCGGCATTGTACCTATGCAGGAAGTTTTGCCGCTCCTGACGGAATACATTGACGAAGATAATATTTCACATC
        +
        B@?&76&&&:55&55)B;6<FFCB:FCC>FB=E>EEEBEEEEEEEEEB=D::8C>>>@C9C;C9>66C,(05345B>B62<39(1BBBBB15<'@*<75D
        @EAS20_8_6_1_3_642/2
        CTTNGANNNTGTNGGTGGGCATCGCTAATATTCGCCTCGTTCTCACGATTCCTCTGTAGTTCAGTCGGTAGAACGGCGGACTGTTAATCCGCATTTCACT
        ubuntu@ip-172-31-23-122:~/work$

11. Interleave the Quality Trimmed PE reads again using khmer:

        ubuntu@ip-172-31-23-122:~/work$ interleave-reads.py trim-R1.fq trim-R2.fq > trim-pe.fq

        || This is the script interleave-reads.py in khmer.
        || You are running khmer version 2.0
        || You are also using screed version 0.9
        ||
        || If you use this script in a publication, please cite EACH of the following:
        ||
        ||   * MR Crusoe et al., 2015. http://dx.doi.org/10.12688/f1000research.6924.1
        ||
        || Please see http://khmer.readthedocs.org/en/latest/citations.html for details.

        Interleaving:
                trim-R1.fq
                trim-R2.fq
        ... 0 pairs
        ... 100000 pairs
        ... 200000 pairs
        ... 300000 pairs
        ... 400000 pairs
        ... 500000 pairs
        ... 600000 pairs
        ... 700000 pairs
        ... 800000 pairs
        ... 900000 pairs
        ... 1000000 pairs
        ... 1100000 pairs
        ... 1200000 pairs
        ... 1300000 pairs
        ... 1400000 pairs
        ... 1500000 pairs
        ... 1600000 pairs
        ... 1700000 pairs
        ... 1800000 pairs
        ... 1900000 pairs
        ... 2000000 pairs
        ... 2100000 pairs
        ... 2200000 pairs
        ... 2300000 pairs
        ... 2400000 pairs
        final: interleaved 2495801 pairs
        output written to block device
        ubuntu@ip-172-31-23-122:~/work$
        
12. Check the interleaved, trimmed PE fastq file:        

        ubuntu@ip-172-31-23-122:~/work$ head -16 trim-pe.fq
        @EAS20_8_6_1_3_2012/1
        GAAACAGCGCCAGCCCGCAGTAAAAACCGATGCGACTGAGTGTGCGTTTATTTGTTGCCATTGAGGTTCACCCGTTTCCTGGTCAGCAGAATGACAGCGA
        +
        HHHHHHHHGHHHHHHGHGDHHHEBEDHHH@FFFHAEGHGGACEHFHEGEEHHEEGGHDGAHGE5GGGGG>HFGDEDGEEH@45@57=7:9<DE9E??1@<
        @EAS20_8_6_1_3_2012/2
        TTTNCTNNNGACNAAGGTCGATATTCTCGGTGTATATCTCTACAAAACCGCCTTTGCCTTTAATGATTTAGGAAAAGCGGCGGCGGTCTCGGTGGTTGTC
        +
        554%55&%%455&54;+86:>EEEEEEEEE>EEEEEEEE:EEEEEE>EEEEEEEEEEEEEE=EEEEEEEE;)?<77@+C@C###################
        @EAS20_8_6_1_3_725/1
        GAAACATGGGCCAGCTGGTTGTCATTTAATAATGTGAGAATGGTGTCTTCGCCTGCTTCTGGCGCGTACTCCGCCATCACTTCTTCACGACTTAACTTCC
        +
        HHHHHHHHHHHHHHHHHHHHHHHHHHHHDHHFHHIHGHEFHF:GDHHHHHEHGGEGHIHHHEHCGAEGGGGHEHG1CC=CGGGGFGGGBFGGGFGCGGGG
        @EAS20_8_6_1_3_725/2
        ATGNGTNNNTCGNTGGCGATCCTGACCATCGGCATTGTACCTATGCAGGAAGTTTTGCCGCTCCTGACGGAATACATTGACGAAGATAATATTTCACATC
        +
        B@?&76&&&:55&55)B;6<FFCB:FCC>FB=E>EEEBEEEEEEEEEB=D::8C>>>@C9C;C9>66C,(05345B>B62<39(1BBBBB15<'@*<75D

13. Assemble the Quality Trimmed reads in the interleaved PE fastq file using MEGAHIT

        ubuntu@ip-172-31-23-122:~/work$ ~/megahit/megahit --12 trim-pe.fq -r orphan-R1.fq,orphan-R2.fq -o 
        ecoli_trimmed
        15.671Gb memory in total.
        Using: 14.104Gb.
        MEGAHIT v1.1.1-2-g02102e1
        --- [Thu Mar  2 23:05:04 2017] Start assembly. Number of CPU threads 4 ---
        --- [Thu Mar  2 23:05:04 2017] Available memory: 16826142720, used: 15143528448
        --- [Thu Mar  2 23:05:04 2017] Converting reads to binaries ---
        b'    [read_lib_functions-inl.h  : 209]     Lib 0 (trim-pe.fq): interleaved, 4991602 reads, 100 max length'
        b'    [read_lib_functions-inl.h  : 209]     Lib 1 (orphan-R1.fq): se, 3712 reads, 100 max length'
        b'    [read_lib_functions-inl.h  : 209]     Lib 2 (orphan-R2.fq): se, 461 reads, 100 max length'
        b'    [utils.h                   : 126]     Real: 4.2892\tuser: 3.8280\tsys: 0.4560\tmaxrss: 159400'
        --- [Thu Mar  2 23:05:08 2017] k-max reset to: 119 ---
        --- [Thu Mar  2 23:05:08 2017] k list: 21,29,39,59,79,99,119 ---
        --- [Thu Mar  2 23:05:08 2017] Extracting solid (k+1)-mers for k = 21 ---
        --- [Thu Mar  2 23:06:16 2017] Building graph for k = 21 ---
        --- [Thu Mar  2 23:06:22 2017] Assembling contigs from SdBG for k = 21 ---
        --- [Thu Mar  2 23:06:35 2017] Local assembling k = 21 ---
        --- [Thu Mar  2 23:07:08 2017] Extracting iterative edges from k = 21 to 29 ---
        --- [Thu Mar  2 23:07:35 2017] Building graph for k = 29 ---
        --- [Thu Mar  2 23:07:37 2017] Assembling contigs from SdBG for k = 29 ---
        --- [Thu Mar  2 23:07:44 2017] Local assembling k = 29 ---
        --- [Thu Mar  2 23:08:05 2017] Extracting iterative edges from k = 29 to 39 ---
        --- [Thu Mar  2 23:08:26 2017] Building graph for k = 39 ---
        --- [Thu Mar  2 23:08:28 2017] Assembling contigs from SdBG for k = 39 ---
        --- [Thu Mar  2 23:08:35 2017] Local assembling k = 39 ---
        --- [Thu Mar  2 23:08:53 2017] Extracting iterative edges from k = 39 to 59 ---
        --- [Thu Mar  2 23:09:11 2017] Building graph for k = 59 ---
        --- [Thu Mar  2 23:09:14 2017] Assembling contigs from SdBG for k = 59 ---
        --- [Thu Mar  2 23:09:21 2017] Local assembling k = 59 ---
        --- [Thu Mar  2 23:09:36 2017] Extracting iterative edges from k = 59 to 79 ---
        --- [Thu Mar  2 23:09:47 2017] Building graph for k = 79 ---
        --- [Thu Mar  2 23:09:49 2017] Assembling contigs from SdBG for k = 79 ---
        --- [Thu Mar  2 23:09:55 2017] Local assembling k = 79 ---
        --- [Thu Mar  2 23:10:10 2017] Extracting iterative edges from k = 79 to 99 ---
        --- [Thu Mar  2 23:10:17 2017] Building graph for k = 99 ---
        --- [Thu Mar  2 23:10:19 2017] Assembling contigs from SdBG for k = 99 ---
        --- [Thu Mar  2 23:10:24 2017] Local assembling k = 99 ---
        --- [Thu Mar  2 23:10:37 2017] Extracting iterative edges from k = 99 to 119 ---
        --- [Thu Mar  2 23:10:38 2017] Building graph for k = 119 ---
        --- [Thu Mar  2 23:10:39 2017] Assembling contigs from SdBG for k = 119 ---
        --- [Thu Mar  2 23:10:44 2017] Merging to output final contigs ---
        --- [STAT] 117 contigs, total 4577092 bp, min 220 bp, max 246618 bp, avg 39120 bp, N50 105708 bp
        --- [Thu Mar  2 23:10:44 2017] ALL DONE. Time elapsed: 340.382027 seconds ---
        
14. Save a copy of the final trimmed assembly to the work directory:

        ubuntu@ip-172-31-23-122:~/work$ cp ecoli_trimmed/final.contigs.fa ./ecoli-assembly_trimmed.fa


15. Run QUAST on the assembly that was generated using the trimmed PE reads + orphan single reads:

        ubuntu@ip-172-31-23-122:~/work$ python2.7 ~/quast/quast.py ecoli-assembly_trimmed.fa -o ecoli_report
        /home/ubuntu/quast/quast.py ecoli-assembly_trimmed.fa -o ecoli_report

        Version: 4.2

        System information:
          OS: Linux-4.2.0-30-generic-x86_64-with-Ubuntu-15.10-wily (linux_64)
          Python version: 2.7.10
          CPUs number: 4

        Started: 2017-03-02 23:25:40

        Logging to /home/ubuntu/work/ecoli_report/quast.log
        NOTICE: Maximum number of threads is set to 1 (use --threads option to set it manually)

        Main parameters:
          Threads: 1, minimum contig length: 500, ambiguity: one, threshold for extensive misassembly size: 1000

        WARNING: Can't draw plots: please install python-matplotlib.

        Contigs:
          ecoli-assembly_trimmed.fa ==> ecoli-assembly_trimmed

        2017-03-02 23:25:40
        Running Basic statistics processor...
          Contig files:
            ecoli-assembly_trimmed
          Calculating N50 and L50...
            ecoli-assembly_trimmed, N50 = 105708, L50 = 15, Total length = 4572220, GC % = 50.74, # N's per 100 kbp =  
            0.00
        Done.

        NOTICE: Genes are not predicted by default. Use --gene-finding option to enable it.

        2017-03-02 23:25:41
        Creating large visual summaries...
        This may take a while: press Ctrl-C to skip this step..
          1 of 1: Creating Icarus viewers...
        Done

        2017-03-02 23:25:41
        RESULTS:
          Text versions of total report are saved to /home/ubuntu/work/ecoli_report/report.txt, report.tsv, and 
          report.tex
          Text versions of transposed total report are saved to /home/ubuntu/work/ecoli_report/transposed_report.txt, 
          transposed_report.tsv,
         and transposed_report.tex
          HTML version (interactive tables and plots) saved to /home/ubuntu/work/ecoli_report/report.html
          Icarus (contig browser) is saved to /home/ubuntu/work/ecoli_report/icarus.html
          Log saved to /home/ubuntu/work/ecoli_report/quast.log

        Finished: 2017-03-02 23:25:41
        Elapsed time: 0:00:00.463645
        NOTICEs: 2; WARNINGs: 1; non-fatal ERRORs: 0

        Thank you for using QUAST!
        ubuntu@ip-172-31-23-122:~/work$
        
16. Look at the QUAST summary stats for the MEGAHIT assembly of the trimmed PE reads + single read orphans:

        All statistics are based on contigs of size >= 500 bp, unless otherwise noted (e.g., "# contigs (>= 0 bp)" and 
        "Total length (>= 0 bp)" include all contigs).

        Assembly                    ecoli-assembly_trimmed
        # contigs (>= 0 bp)         117                   
        # contigs (>= 1000 bp)      93                    
        # contigs (>= 5000 bp)      69                    
        # contigs (>= 10000 bp)     64                    
        # contigs (>= 25000 bp)     52                    
        # contigs (>= 50000 bp)     32                    
        Total length (>= 0 bp)      4577092               
        Total length (>= 1000 bp)   4566004               
        Total length (>= 5000 bp)   4508060               
        Total length (>= 10000 bp)  4470849               
        Total length (>= 25000 bp)  4295882               
        Total length (>= 50000 bp)  3578702               
        # contigs                   102                   
        Largest contig              246618                
        Total length                4572220               
        GC (%)                      50.74                 
        N50                         105708                
        N75                         53842                 
        L50                         15                    
        L75                         30                    
        # N's per 100 kbp           0.00  
        
17. Compare the stats from the trimmed read assembly (above) to the untrimmed read assembly (below):

        All statistics are based on contigs of size >= 500 bp, unless otherwise noted (e.g., "# contigs (>= 0 bp)" and 
        "Total length (>= 0 bp)" include all contigs).

        Assembly                    ecoli-assembly
        # contigs (>= 0 bp)         117           
        # contigs (>= 1000 bp)      93            
        # contigs (>= 5000 bp)      69            
        # contigs (>= 10000 bp)     64            
        # contigs (>= 25000 bp)     52            
        # contigs (>= 50000 bp)     32            
        Total length (>= 0 bp)      4577284       
        Total length (>= 1000 bp)   4566196       
        Total length (>= 5000 bp)   4508252       
        Total length (>= 10000 bp)  4471041       
        Total length (>= 25000 bp)  4296074       
        Total length (>= 50000 bp)  3578894       
        # contigs                   102           
        Largest contig              246618        
        Total length                4572412       
        GC (%)                      50.74         
        N50                         105708        
        N75                         53842         
        L50                         15            
        L75                         30            
        # N's per 100 kbp           0.00  
   
   
   __SH:__ Comparing the two assemblies, they are nearly identical. The trimmed read assembly has a slightly shorter total length by 192 bp. The largest contig size is the same for both assemblies. Total number of contigs are the same at 102, and the same largest contig was assembled in both cases. N50, N75, L50 and L75 metrics are identical in both assemblies. The main differences observed were in the total length of assemblies where the contigs were greater than or equal to a particular length, namely 50,000bp, 25,000bp, 10,000bp, 5,000bp and 0bp. In each of these cases, the total lengths were shorter for the trimmed read assemblies than in the case of the untrimmed read assemblies.



        
        





