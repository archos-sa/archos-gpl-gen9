1) If you have this from gitorious, you also need to get the kernel
   and place it into a folder named "linux-ics":

       git clone git@gitorious.org:archos/archos-gpl-gen9-kernel-ics.git linux-ics

   starting from 4.0.24, the kernel is 3.0.21 and in a separate branch:
   
       cd linux-ics
       
       git checkout -b linux-ics-3.0.21 origin/linux-ics-3.0.21
   
2) To build, type "make" in the buildroot folder.
