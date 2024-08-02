#!/usr/bin/env bash

odin build Source -file -out:updater -microarch:native -no-bounds-check -o:speed
