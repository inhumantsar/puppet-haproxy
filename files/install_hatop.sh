#!/bin/bash
cd /tmp/
tar xvfz hatop-0.7.7.tar.gz
cd hatop-0.7.7
install -m 755 bin/hatop /usr/local/bin
install -m 644 man/hatop.1 /usr/local/share/man/man1
gzip /usr/local/share/man/man1/hatop.1

