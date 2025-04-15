![Cat on server](https://raw.githubusercontent.com/lateralblast/uwu/master/uwu.jpg)

UWU
----

Ubuntu Working/Monitoring UPS

Version
-------

Current version: 0.1.9

Introduction
------------

This is intended to provide a template for configuring UPS monitoring on Ubuntu.

It was driven out of the CyberUPS monitoring software not reliably triggering,
and wanting something more lightweight than a fully configured nut installation.
It uses the the uspc command from the NUT package to get values from the UPS and act on then.
It can be run from cron or similar to check the status, e.g. every 5 or 10mins.

Requirements
------------

NUT (Network UPS Tools) is required.

Installing on Ubuntu:

```
sudo apt update
sudo apt install nut nut-server nut-client
```

You can search for USB based UPSes, using a number of methods. using the nut-scanner tool, or lsusb.


```
sudo nut-scanner -U
```

I found this did not work and had to run lsbusb to get the required information:

```
lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 0764:0501 Cyber Power System, Inc. CP1500 AVR UPS
Bus 001 Device 003: ID 0781:5583 SanDisk Corp. Ultra Fit
Bus 001 Device 004: ID 8087:0a2b Intel Corp. Bluetooth wireless interface
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

I then added this intomation to /etc/nut/ups.conf:

```
[cps]
  driver = usbhid-ups
  port = auto
  productid = 0501
  desc = “Cyber Power System, Inc. CP1500 AVR UPS”
```

Currently this script runs on the machine the UPS is attached to, so I run the NUT server in standalone mode.
This is done by adding/changing the MODE entry in /etc/nut/nut.conf:

```
MODE=standalone
```

This can be tested by using upsc manually:

```
$ upsc cps battery.charge
94
```

Features
--------

The script currently supports outputing to the console (default), or using slack webhooks.
The slack webhook can be imbedded in the script, input from the commmand line,
or from a file ($HOME/.uwu/slackwebhook).

Examples
--------

Get full status:

```
./uwu.sh --action getfullstatus
battery.charge: 100
battery.charge.low: 10
battery.charge.warning: 20
battery.mfr.date: CPS
battery.runtime: 7200
battery.runtime.low: 300
battery.type: PbAcid
battery.voltage: 12.7
battery.voltage.nominal: 12
device.mfr: CPS
device.model: BR700ELCD
device.type: ups
driver.debug: 0
driver.flag.allow_killpower: 0
driver.name: usbhid-ups
driver.parameter.pollfreq: 30
driver.parameter.pollinterval: 2
driver.parameter.port: auto
driver.parameter.productid: 0501
driver.parameter.synchronous: auto
driver.state: quiet
driver.version: 2.8.1
driver.version.data: CyberPower HID 0.8
driver.version.internal: 0.52
driver.version.usb: libusb-1.0.27 (API: 0x100010a)
input.transfer.high: 0
input.transfer.low: 0
input.voltage: 242.0
input.voltage.nominal: 230
output.voltage: 242.0
ups.beeper.status: enabled
ups.delay.shutdown: 20
ups.delay.start: 30
ups.load: 3
ups.mfr: CPS
ups.model: BR700ELCD
ups.productid: 0501
ups.realpower.nominal: 420
ups.status: OL
ups.test.result: No test initiated
ups.timer.shutdown: -60
ups.timer.start: -60
ups.vendorid: 0764
```

Get battery status:

```
./uwu.sh --action getstatus --param battery.charge
100
```

Post battery status to slack:

```
./uwu.sh --action slackstatus --param battery.charge
```

Post battery status to slack if it not 100:

```
./uwu.sh --action slackalert --param battery.charge --value 100
```

Post battery status to slack if it is less than 90:

```
./uwu.sh --action slackalert --param battery.charge --less --value 90
```

Example cron entry:

```
*/5 * * * * /home/user/bin/ups_check.sh
```

Example script:

```
#!/usr/bin/bash
/home/sysadmin/bin/uwu.sh --action slackalert --param battery.charge --value 100 --location "Workshop" --options verbose
```

Usage Information
-----------------

Getting general help:

```
./uwu.sh --help

Usage: uwu.sh --switch [value]

switch(s):
---------
--action*)
    Action to perform
--debug)
    Enable debug mode
--desc)
    UPS description
--driver)
    UPS driver
--dryrun)
    Enable dryrun mode
--endpoint)
    Post endpoint
--equal*)
    Equal to check
--force)
    Enable force mode
--greater*)
    Greater than check
--hostname)
    Nuts mode
--less*)
    Less than check
--location)
    Location to prefix message with
--mode)
    Nuts mode
--name)
    UPS name
--option*)
    Action to perform
--param)
    UPS param to get
--port)
    UPS port
--productid)
    UPS product
--strict)
    Enable strict mode
--test)
    Enable test mode
--usage*)
    Action to perform
--value)
    UPS value to check
--verbose)
    Enable verbose mode
--version|-V)
    Print version information
--webhook|--slackwebhook)
    Slack webhook
--webhookfile|--slackwebhookfile)
    Slack webhook file
--help|-h)
    Print help information
```

Get help about actions:

```
./uwu.sh --usage action

Usage: uwu.sh --action [value]

action(s):
---------
addups)
    Add UPS
alertstatus|checkstatus)
    Get UPS info
checkenv*)
    Check environment
getmode)
    Get mode
getfullupsstatus|getfullstatus)
    Get Full UPS status
getupsinfo|getinfo)
    Get UPS info
getupsname|getname)
    Get UPS name
getupsstatus|getstatus)
    Get UPS status
help)
    Print actions help
version)
    Print version
postalertstatus)
    Get UPS info
postupsstatus|poststatus)
    Post UPS status
printenv*)
    Print environment
printdefaults|defaults)
    Print defaults
setmode)
    Set nut mode
slackalertstatus|slackalert)
    Post UPS status to slack
slackupsstatus|slackstatus)
    Post UPS status to slack
shellcheck)
    Shellcheck script
```

Get help about options:

```
./uwu.sh --usage option

Usage: uwu.sh --option [value]

option(s):
---------
yes (default = "false"#option)
   Answer yes to all questions
test (default = "false"#option)
   Run in test mode
debug (default = "false"#option)
   Run in debug mode
force (default = "false"#option)
   Force action
print (default = "false"#option)
   Print to console
strict (default = "false"#option)
   Run is strict mode
dryrun (default = "false"#option)
   Run in dryrun mode
verbose (default = "false"#option)
   Run in verbose mode
masked (default = "false"#option)
   Mask sensitive information in console output where possible
less (default = "false"#option)
   Less than check
greater (default = "false"#option)
   Greater than check
equal (default = "false"#option)
   Equal to check
```
