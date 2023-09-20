# Banking app written in Elixir to perform actions like 
Deposit amount to User account, 
Withdraw amount from User account, 
Get Balance of a User and
Fund Transfer between users

Used Dynamic Supervisor to start a GenServer per User. And also used Registry to store the pid of GenServer with key as UserId
Stored Amount, Currency details of User in GenServer State

Used ETS counter to store the number of requests handled for a particular user account concurrently. 
USing that counter to reject requests when exceeded the maximul allowed limit per user.
