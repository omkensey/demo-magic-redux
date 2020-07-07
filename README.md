# demo-magic-redux
@paxtonhare's [demo-magic](https://github.com/paxtonhare/demo-magic) with some improvements to make demos more realistic

demo-magic.sh is a handy shell script that enables you to script repeatable demos in a bash environment so you don't have to type as you present. Rather than trying to type commands when presenting you simply script them and let demo-magic.sh run them for you.

## Features
- Simulates typing. It looks like you are actually typing out commands
- Allows you to actually run commands or pretend to do so.
- Can hide commands from presentation. Useful for behind the scenes stuff that doesn't need to be shown.

## Functions

### start_demo
Clears the terminal and prints an initial prompt.

### end_demo
Prints a final blank line to make the return to the user's real prompt clean.

### pe
Print and Execute. This function will simulate typing whatever you give it. 

```bash
pe "ls -l"
```

### p
Print only. This function will simulate typing whatever you give it. It will 
not run the command.

```bash
p "ls -l"
```

By default both pe and p wait for a keypress before simulated typing (see 
`wait` below).  You can configure whether and where these waits happen with 
the NO_WAIT/-n and WAIT_AT/-a variables/options when invoking demo-magic.

### pei
Types and runs the given command immediately, with no waits.  Useful if you 
want most commands to wait, but want to skip the waits between some (e.g. 
when multiple commands are related to the same task and you want to execute 
them as a group with no waits in between).

```bash
pei "ls -l"
```

### wait
Waits for the user to press <kbd>ENTER</kbd>.  You can use this alone any 
time you want the script to pause at an arbitrary point.

If `PROMPT_TIMEOUT` is defined and > 0 the demo will automatically proceed after the amount of seconds has passed.

```bash
# Will wait until user presses enter
PROMPT_TIMEOUT=0
wait

# Will wait max 5 seconds until user presses
PROMPT_TIMEOUT=5
wait
```

### cmd
Enters script into interactive mode and allows newly typed commands to be executed within the script

```
cmd
```

## Getting Started
Create a shell script and include demo-magic.sh

```bash
#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh

# hide the evidence
start_demo

# Put your stuff here
```

Then use the handy functions to run through your demo.

## Command line usage
demo-magic.sh exposes 6 options out of the box to your script.
- `-h` - prints the usage text
- `-a` - set where demo-magic waits when simulating typing (before, after, or both)
- `-d` - disable simulated typing. Useful for debugging
- `-n` - set no default waiting after `p` and `pe` functions
- `-s` - set the simulated typing speed (default speed is 20)
- `-w` - set no wait timeout after `p` and `pe` functions

```bash
$ ./demo-magic.sh -h

Usage: ./demo-magic.sh [options]

	Where options is one or more of:
	-h	Prints Help text
	-a	Whether to wait before or after simulated typing for user 
		to hit enter (before, after, both)
	-d	Debug mode. Disables simulated typing
	-n	No wait
	-s	Typing speed (default: 20)
	-w	Waits max the given amount of seconds before proceeding 
		with demo (e.g. '-w5')
```

## Useful Tricks

Network connections during demos are often unreliable. Try and fake whatever 
commands would rely on a network connection. For example: Instead of trying 
to install node modules in a node.js application you can fake it. You can 
install the node_modules at home on your decent network. Then rename the 
directory and pretend to install it later by symlinking. If you want to be 
thorough you can capture the output of npm install into a log file then cat 
it out later to simulate the install.

```bash
#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh

# hide the evidence
start_demo

# this command is typed and executed
pe "cd my-app"

# this command is merely typed. Not executed
p "npm install"

# this command runs behind the scenes
ln -s cached_node_modules node_modules

# cat out a log file that captures a previous successful node modules install
cat node-modules-install.log

# now type and run the command to start your app
pe "node index.js"

# finish up
end_demo
```

### No waiting
The -n _no wait_ option can be useful if you want to print and execute multiple commands.

```bash
# include demo-magic
. demo-magic.sh -n

# add multiple commands
pe 'git status'
pe 'git log --oneline --decorate -n 20'
```

However this will oblige you to define your waiting points manually e.g.
```bash
...
# define waiting points
pe 'git status'
pe 'git log --oneline --decorate -n 20'
wait
pe 'git pull'
pe 'git log --oneline --decorate -n 20'
wait
```

