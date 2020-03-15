#!/bin/bash
npm --prefix lambda-packer install
npm --prefix lambda-packer run build
npm --prefix send-push-notification install
npm --prefix send-push-notification run build
npm --prefix send-doorbell-notification install
npm --prefix send-doorbell-notification run pack
npm --prefix register-device install
npm --prefix register-device run pack
