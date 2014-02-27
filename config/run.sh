#!/bin/bash
/etc/init.d/sendmail start &
/usr/bin/supervisord
