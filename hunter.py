#!/usr/bin/env python3
import socket
import sys
import subprocess
from termcolor import colored



print ( colored(''' 
          ##        ##   ##        ##  ####       ##  ############  #######    ############  
          ##        ##   ##        ##  ## ##      ##       ##       ##         ##        ##
          ##        ##   ##        ##  ##  ##     ##       ##       ##         ##       ##
          ############   ##        ##  ##   ##    ##       ##       ######     #########  
          ##        ##   ##        ##  ##     ##  ##       ##       ##         ##     ## 
          ##        ##   ##        ##  ##      ## ##       ##       ##         ##      ##
          ##        ##      ######     ##       ####       ##       #######    ##       ## 
                                                                                          
                  -by S-SEC GROUP as @ssecgroup twitter, github  >> www.pingnetworks.org  ''','red', attrs=['dark','bold']))
       
                                            
        





f1=[subprocess.run("/home/reddevil/Documents/myprjct/core.sh", shell=True)]
cmd = subprocess.Popen(f1).wait()
cmd.communicate()



