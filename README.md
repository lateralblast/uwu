![Cat on server](https://raw.githubusercontent.com/lateralblast/uwu/master/uwu.jpg)

UWU
----

Ubuntu Working/Monitoring Ups

Version
-------

Current version: 0.1.3

Introduction
------------

This is intended to provide a template for configuring UPS monitoring on Ubuntu.

It was driven out of the CyberUPS monitoring software not reliably triggering,
and wanting something more lightweight than a fully configured nut installation.
It uses the the uspc command to get values from the UPS and act on then.
It can be run from cron or similar to check the status, e.g. every 5 or 10mins.

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
--endpoint)
    Post endpoint
--force)
    Enable force mode
--hostname)
    Nuts mode
--location)
    Location to prefix message with
--mode)
    Nuts mode
--strict)
    Enable strict mode
--verbose)
    Enable verbos e mode
--version|-V)
    Print version information
--option*)
    Action to perform
--param)
    UPS param to get
--port)
    UPS port
--productid)
    UPS product
--usage*)
    Action to perform
--value)
    UPS value to check
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
printdefaults)
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
yes (default = false#option)
   Answer yes to all questions
test (default = false#option)
   Run in test mode
debug (default = false#option)
   Run in debug mode
force (default = false#option)
   Force action
print (default = false#option)
   Print to console
strict (default = false#option)
   Run is strict mode
dryrun (default = false#option)
   Run in dryrun mode
verbose (default = false#option)
   Run in verbose mode
masked (default = false#option)
   Mask sensitive information in console output where possible
```