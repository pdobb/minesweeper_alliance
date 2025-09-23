# frozen_string_literal: true

# User::Current holds namespace-level items for {User::Current::Find} and
# {User::Current::Create}.
module User::Current
  COOKIE = "user_token"
  public_constant :COOKIE
end
