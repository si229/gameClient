-define(INFO(__MSG__),lager:info(__MSG__)).
-define(INFO(__Format__,__MSG__),lager:info(__Format__,__MSG__)).

-define(WARNING(__MSG__),lager:warning(__MSG__)).
-define(WARNING(__Format__,__MSG__),lager:warning(__Format__,__MSG__)).

-define(ERROR(__MSG__),lager:error(__MSG__)).
-define(ERROR(__Format__,__MSG__),lager:error(__Format__,__MSG__)).

-define(MILLI_TIMESTAMP,erlang:system_time(1000)).