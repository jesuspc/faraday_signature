* Rack middleware to interpret the signature and validate it. Once validated
env.trustworthy is set to true, otherwise can either be set to false and continue
or do a custom on_invalid_signature action.
