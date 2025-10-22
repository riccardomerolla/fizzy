#!/usr/bin/env bash

set -e

# fizzy-lb-101.df-iad-int.37signals.com
#
#   Service      Host                      Path    Target                                                                         State    TLS
#   fizzy        fizzy.37signals.com       /       fizzy-app-101.df-iad-int.37signals.com,fizzy-app-02.sc-chi-int.37signals.com   running  yes
#   fizzy-admin  fizzy.37signals.com       /admin  fizzy-app-101.df-iad-int.37signals.com                                         running  yes
ssh app@fizzy-lb-101.df-iad-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy \
      --tls \
      --host=fizzy.37signals.com \
      --target=fizzy-app-101.df-iad-int.37signals.com \
      --read-target=fizzy-app-102.df-iad-int.37signals.com \
      --tls-acme-cache-path=/certificates

ssh app@fizzy-lb-101.df-iad-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy-admin \
      --host=fizzy.37signals.com \
      --path-prefix /admin \
      --strip-path-prefix=false \
      --target=fizzy-app-101.df-iad-int.37signals.com


# fizzy-lb-01.sc-chi-int.37signals.com
#
#   Service      Host                      Path    Target                                                                          State    TLS
#   fizzy        fizzy.37signals.com       /       fizzy-app-101.df-iad-int.37signals.com,fizzy-app-102.df-iad-int.37signals.com   running  yes
#   fizzy-admin  fizzy.37signals.com       /admin  fizzy-app-101.df-iad-int.37signals.com                                          running  yes
ssh app@fizzy-lb-01.sc-chi-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy \
      --tls \
      --host=fizzy.37signals.com \
      --target=fizzy-app-101.df-iad-int.37signals.com \
      --read-target=fizzy-app-02.sc-chi-int.37signals.com \
      --tls-acme-cache-path=/certificates

ssh app@fizzy-lb-01.sc-chi-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy-admin \
      --host=fizzy.37signals.com \
      --path-prefix /admin \
      --strip-path-prefix=false \
      --target=fizzy-app-101.df-iad-int.37signals.com


# fizzy-lb-401.df-ams-int.37signals.com
#
#   Service      Host                      Path    Target                                                                          State    TLS
#   fizzy        fizzy.37signals.com       /       fizzy-app-101.df-iad-int.37signals.com,fizzy-app-402.df-ams-int.37signals.com   running  yes
#   fizzy-admin  fizzy.37signals.com       /admin  fizzy-app-101.df-iad-int.37signals.com                                          running  yes
ssh app@fizzy-lb-401.df-ams-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy \
      --tls \
      --host=fizzy.37signals.com \
      --target=fizzy-app-101.df-iad-int.37signals.com \
      --read-target=fizzy-app-402.df-ams-int.37signals.com \
      --tls-acme-cache-path=/certificates

ssh app@fizzy-lb-401.df-ams-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy-admin \
      --host=fizzy.37signals.com \
      --path-prefix /admin \
      --strip-path-prefix=false \
      --target=fizzy-app-101.df-iad-int.37signals.com
