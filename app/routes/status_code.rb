module StatusCode

  # 2000 success
  Success = 2000

  # 5000 server error
  # 50xx server machine
  ServerError = 5000
  # 51xx logic error


  # 52xx database auth
  UserHaveExist = 5201 #用户已存在
  UserNotExist  = 5202
  # 53xx database data
  InvalidParams = 5301
  RecordHaveExist = 5302
  RecordNotExist = 5303

end
