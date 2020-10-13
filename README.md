# CoreLogging

Logger module has currently supported 4 type of log:

info: appropriate for informational messages
debug: appropriate for messages that contain information normally of use only when debugging a program
error: appropriate for error conditions
warning: appropriate for critical error conditions that usually require immediate attention
Setup CoreLogger Module

Usage
Object-C : 
@import CoreUtilsKit;



Swift:

import CoreUtils



Properties:
message: message to log,
file: file that calls the function
line: line of code from the file where the function is call
function: function that calls the functon
Output

Console Xcode

File saving

The core concepts
Core logger supports configuration print to console, write to local file and properties of message logging.

Log to Xcode console 

set true value to allowToPrint
with Logger Module Xcode can to gets powerful logging functionality to its console including .
Log to File

set true value to allowToLogWrite
save loggers text to "VDSLogger.log" in device data
logging to a file is great for development. You can attach the log file to an email or send it to your server. 
the file location is adjustable and on default the file is stored in the Cache directory of your app.
Log to Screen View

Show screen to view the logging text on your device.

In that page, you also can tap & hold view to moving it, and click button close to hidden this view.

