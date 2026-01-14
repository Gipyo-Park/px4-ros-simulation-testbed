#!/usr/bin/env python3
import subprocess

# Function to open a new terminal with a given command
def open_terminal(title, workdir, command):
    subprocess.Popen([
        'gnome-terminal', '--geometry', '71x24+1248-4',
        '--title={}'.format(title),
        '--working-directory={}'.format(workdir),
        '-e', command
    ])

# Source the .bashrc file (it's usually not needed in a script, but included for completeness)
subprocess.call(['bash', '-c', 'source /etc/skel/.bashrc'])

# Commands to run
open_terminal("ROSCORE", "/home/hmcl/PX4_testbed/automation_codes", "/bin/bash -c 'roscore;bash'")
open_terminal("QGC", "/home/hmcl", "bash -c './QGroundControl.AppImage; bash'")


# The command below is commented out because the arguments ($1, $2, ...) are not defined
# open_terminal("KATECH SILS", "/home/hmcl/PX4_testbed/automation_codes", "/bin/bash -c './set_sils.sh $1 $2 $3 $4 $5 $6 ;bash'")

print('[INFO] Start ROSCORE / QGC / Kill')