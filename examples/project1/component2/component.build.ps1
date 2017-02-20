task Hello { "Hello $Greeting from $ComponentName!" }

task Clear { "Cleaning $ComponentName" }

task Compile { "Compiling $ComponentName" }

task Test { "Testing $ComponentName" }

task . Clear, Compile, Test
