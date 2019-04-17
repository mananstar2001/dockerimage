#!/bin/bash
echo "127.0.0.1	noreply.domain.com $(hostname)" >> /etc/hosts
echo "hello" | sendmail -f mananstar2001@gmail.com manan_sheth@optum.com
