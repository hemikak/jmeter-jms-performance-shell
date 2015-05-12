# jmeter-jms-performance-shell

## Configuration
Modify JMeter path in the run.sh file.  
Modify the project path(current path) in run.sh file with escapes.  
Enable the following in jmeter.properties
  - summariser.name=summary
  - summariser.interval=5
  - summariser.log=true
  - summariser.out=true

## Running Shell
`./run.sh`

## Notes and Known Issues
* If the modified file path is incorrect, use `git reset --hard` to reset the JMX files.  
* Tested on MAC OS X Yosemite only