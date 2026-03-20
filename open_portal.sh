#!/bin/bash

URL="https://eurecaterp.local.eurecat.org/EmployeeServices/Enterprise%20Portal/default.aspx?&WDPK=initial&WMI=EPPersonalInformation&redirected=1&WCMP=ECAT&WMI=EPPersonalInformation"

firefox --new-tab "$URL" >/dev/null 2>&1 &
