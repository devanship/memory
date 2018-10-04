#!/bin/bash

export MIX_ENV=prod
export PORT=4792

echo "Stopping old copy of app, if any..."

_build/prod/rel/memory/bin/memory stop || true

echo "Starting app..."

_build/prod/rel/memory/bin/memory start

<<<<<<< HEAD

=======
>>>>>>> d7a346bd84f9c28db386f9dd770d963c03f7ee39
