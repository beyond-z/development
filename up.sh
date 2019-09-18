#!/bin/bash
( cd canvas-lms-js-css/ && docker-compose up -d )
( cd rubycas-server/ && docker-compose up -d )
( cd beyondz-platform/ && docker-compose up -d )
( cd canvas-lms/ && docker-compose up -d )
( cd nginx-dev/ && docker-compose up -d )

