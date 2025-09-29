import 'package:kitokopay/models/loan_details_response.dart';

class GlobalData {
  static final GlobalData _singleton = GlobalData._internal();

  factory GlobalData() {
    return _singleton;
  }

  GlobalData._internal()
      : _publicKey = '',
        _coreDataResult = '',
        _appId = '',
        _customerId = '',
        _userStatus = '',
        _is401ActivationResponse = 0,
        _is400ActivationResponse = 0,
        _is401LoginResponse = 0,
        _is400LoginResponse = 0,
        _mobileNumber = '',
        _limitAmount = '',
        _displayLimit = '',
        _limitMessage = '',
        _loanTermPeriod = '',
        _interestRate = '',
        _firstName = '',
        _loanCurrency = '',
        _requestLoanAmount = '',
        _loanId = '',
        _lastName = '',
        _totalOutstanding = '',
        _pastDueDays = '',
        _totalPrincipalDisbursed = '',
        _loanDetailsId = '',
        _loanDetailsInterestRate = '',
        _principal = '',
        _totalPrincipalExpected = '',
        _totalRepaymentExpected = '',
        _loanTransactionAmount = '',
        _loanTransactionDate = '',
        _loanTransactionBalance = '',
        _loanTransactionReceiptNumber = '',
        _loanTransactionId = '',
        _loginLoanId = '',
        _is401LoanDetailsResponse = 0,
        _is400LoanDetailsResponse = 0,
        _loanTransactionType = '',
        _loanTransactions = [],
        // _loanDetails = [],
        _activateCoreDataResult = '',
        _loginCoreDataResult = '',
        _loanDetailsCoreDataResult = '',
        _applicationCoreDataResult = '',
        _reactivateCoreDataResult = '',
        _is401ReactivateResponse = 0,
        _is400ReactivateResponse = 0,
        _is200ResetPinStatusCode = 0,
        _is401ResetPinResponse = 0,
        _is400ResetPinResponse = 0,
        _emailAddress = '',
        _is400LoanApplicationUsingBio = 0,
        _is401LoanApplicationUsingPin = 0,
        _is400LoanApplicationUsingPin = 0,
        _is401LoanApplicationUsingBio = 0,
        _is200LoanApplicationUsingBio = 0,
        _is200LoanApplicationUsingPin = 0,
        _deviceId = '',
        _requestLoanCurrency = '',
        _loanDetailsCurrency = '',
        _convertedLimitAmount = '',
        _usdRate = '';

  String _publicKey;
  String _coreDataResult;
  String _appId;
  String _customerId;
  String _userStatus;
  int _is401ActivationResponse;
  int _is400ActivationResponse;
  String _mobileNumber;
  String _limitAmount;
  String _displayLimit;
  String _limitMessage;
  String _loanTermPeriod;
  String _interestRate;
  int _is401LoginResponse;
  int _is400LoginResponse;
  String _firstName;
  String _loanCurrency;
  String _requestLoanAmount;
  String _loanId;
  String _lastName;
  String _totalOutstanding;
  String _pastDueDays;
  String _totalPrincipalDisbursed;
  String _loanDetailsId;
  String _loanDetailsInterestRate;
  String _principal;
  String _totalPrincipalExpected;
  String _totalRepaymentExpected;
  String _loanTransactionAmount;

  String _loanTransactionDate;
  String _loanTransactionBalance;
  String _loanTransactionReceiptNumber;
  String _loanTransactionId;
  String _loginLoanId;
  int _is401LoanDetailsResponse;
  int _is400LoanDetailsResponse;
  String _loanTransactionType;
  List<Transaction> _loanTransactions;
  // List<Details> _loanDetails;
  String _activateCoreDataResult;
  String _loginCoreDataResult;
  String _loanDetailsCoreDataResult;
  String _applicationCoreDataResult;
  String _reactivateCoreDataResult;
  int _is401ReactivateResponse;
  int _is400ReactivateResponse;
  int _is200ResetPinStatusCode;
  int _is401ResetPinResponse;
  int _is400ResetPinResponse;
  String _emailAddress;
  int _is400LoanApplicationUsingBio;
  int _is401LoanApplicationUsingPin;
  int _is400LoanApplicationUsingPin;
  int _is401LoanApplicationUsingBio;
  int _is200LoanApplicationUsingBio;
  int _is200LoanApplicationUsingPin;
  String _deviceId;
  String _requestLoanCurrency;
  String _loanDetailsCurrency;
  String _convertedLimitAmount;
  String _usdRate;

  void setPublicKey(String publicKey) {
    _publicKey = publicKey;
  }

  String getPublicKey() {
    return _publicKey;
  }

  void setCoreDataResult(String coreResult) {
    _coreDataResult = coreResult;
  }

  String getCoreDataResult() {
    return _coreDataResult;
  }

  void setAppId(String appId) {
    _appId = appId;
  }

  String getAppId() {
    return _appId;
  }

  void setCustomerId(String customerId) {
    _customerId = customerId;
  }

  String getCustomerId() {
    return _customerId;
  }

  void setUserStatus(String userStatus) {
    _userStatus = userStatus;
  }

  String getUserStatus() {
    return _userStatus;
  }

  void setIs401ActivationResponse(int is401ActivationResponse) {
    _is401ActivationResponse = is401ActivationResponse;
  }

  int getIs401ActivationResponse() {
    return _is401ActivationResponse;
  }

  void setIs400ActivationResponse(int is400ActivationResponse) {
    _is400ActivationResponse = is400ActivationResponse;
  }

  int getIs400ActivationResponse() {
    return _is400ActivationResponse;
  }

  void setMobileNumber(String mobileNumber) {
    _mobileNumber = mobileNumber;
  }

  String getMobileNumber() {
    return _mobileNumber;
  }

  void setLimitAmount(String limitAmount) {
    _limitAmount = limitAmount;
  }

  String getLimitAmount() {
    return _limitAmount;
  }

  void setLimitMessage(String limitMessage) {
    _limitMessage = limitMessage;
  }

  String getLimitMessage() {
    return _limitMessage;
  }

  void setLoanTermPeriod(String loanTermPeriod) {
    _loanTermPeriod = loanTermPeriod;
  }

  String getLoanTermPeriod() {
    return _loanTermPeriod;
  }

  void setInterestRate(String interestRate) {
    _interestRate = interestRate;
  }

  String getInterestRate() {
    return _interestRate;
  }

  void setIs401LoginResponse(int is401LoginResponse) {
    _is401LoginResponse = is401LoginResponse;
  }

  int getIs401LoginResponse() {
    return _is401LoginResponse;
  }

  void setIs400LoginResponse(int is400LoginResponse) {
    _is400LoginResponse = is400LoginResponse;
  }

  int getIs400LoginResponse() {
    return _is400LoginResponse;
  }

  void setFirstName(String firstName) {
    _firstName = firstName;
  }

  String getFirstName() {
    return _firstName;
  }

  void setLoanCurrency(String loanCurrency) {
    _loanCurrency = loanCurrency;
  }

  String getLoanCurrency() {
    return _loanCurrency;
  }

  void setRequestLoanAmount(String requestLoanAmount) {
    _requestLoanAmount = requestLoanAmount;
  }

  String getRequestLoanAmount() {
    return _requestLoanAmount;
  }

  void setLoanId(String loanId) {
    _loanId = loanId;
  }

  String getLoanId() {
    return _loanId;
  }

  void setLastName(String lastName) {
    _lastName = lastName;
  }

  String getLastName() {
    return _lastName;
  }

  void setTotalOutstanding(String totalOutstanding) {
    _totalOutstanding = totalOutstanding;
  }

  String getTotalOutstanding() {
    return _totalOutstanding;
  }

  void setPastDueDays(String pastDueDays) {
    _pastDueDays = pastDueDays;
  }

  String getPastDueDays() {
    return _pastDueDays;
  }

  void setTotalPrincipalDisbursed(String totalPrincipalDisbursed) {
    _totalPrincipalDisbursed = totalPrincipalDisbursed;
  }

  String getTotalPrincipalDisbursed() {
    return _totalPrincipalDisbursed;
  }

  void setLoanDetailsId(String loanDetailsId) {
    _loanDetailsId = loanDetailsId;
  }

  String getLoanDetailsId() {
    return _loanDetailsId;
  }

  void setLoanDetailsInterestRate(String loanDetailsInterestRate) {
    _loanDetailsInterestRate = loanDetailsInterestRate;
  }

  String getLoanDetailsInterestRate() {
    return _loanDetailsInterestRate;
  }

  void setPrincipal(String principal) {
    _principal = principal;
  }

  String getPrincipal() {
    return _principal;
  }

  void setTotalPrincipalExpected(String totalPrincipalExpected) {
    _totalPrincipalExpected = totalPrincipalExpected;
  }

  String getTotalPrincipalExpected() {
    return _totalPrincipalExpected;
  }

  void setTotalRepaymentExpected(String totalRepaymentExpected) {
    _totalRepaymentExpected = totalRepaymentExpected;
  }

  String getTotalRepaymentExpected() {
    return _totalRepaymentExpected;
  }

  void setLoanTransactionAmount(String loanTransactionAmount) {
    _loanTransactionAmount = loanTransactionAmount;
  }

  String getLoanTransactionAmount() {
    return _loanTransactionAmount;
  }

  void setLoanTransactionDate(String loanTransactionDate) {
    _loanTransactionDate = loanTransactionDate;
  }

  String getLoanTransactionDate() {
    return _loanTransactionDate;
  }

  void setLoanTransactionBalance(String loanTransactionBalance) {
    _loanTransactionBalance = loanTransactionBalance;
  }

  String getLoanTransactionBalance() {
    return _loanTransactionBalance;
  }

  void setLoanTransactionReceiptNumber(String loanTransactionReceiptNumber) {
    _loanTransactionReceiptNumber = loanTransactionReceiptNumber;
  }

  String getLoanTransactionReceiptNumber() {
    return _loanTransactionReceiptNumber;
  }

  void setLoanTransactionId(String loanTransactionId) {
    _loanTransactionId = loanTransactionId;
  }

  String getLoanTransactionId() {
    return _loanTransactionId;
  }

  void setLoginLoanId(String loginLoanId) {
    _loginLoanId = loginLoanId;
  }

  String getLoginLoanId() {
    return _loginLoanId;
  }

  void setIs401LoanDetailsResponse(int is401LoanDetailsResponse) {
    _is401LoanDetailsResponse = is401LoanDetailsResponse;
  }

  int getIs401LoanDetailsResponse() {
    return _is401LoanDetailsResponse;
  }

  void setIs400LoanDetailsResponse(int is400LoanDetailsResponse) {
    _is400LoanDetailsResponse = is400LoanDetailsResponse;
  }

  int getIs400LoanDetailsResponse() {
    return _is400LoanDetailsResponse;
  }

  void setLoanTransactionType(String loanTransactionType) {
    _loanTransactionType = loanTransactionType;
  }

  String getLoanTransactionType() {
    return _loanTransactionType;
  }

  // void setLoanTransactions(List<Transaction> loanTransactions) {
  //   _loanTransactions = loanTransactions;
  // }

  List<Transaction> getLoanTransactions() {
    return _loanTransactions;
  }

  // void setLoanDetails(List<Details> loanDetails) {
  //   _loanDetails = loanDetails;
  // }

  // List<Details> getLoanDetails() {
  //   return _loanDetails;
  // }

  void setActivateCoreDataResult(String activateCoreDataResult) {
    _activateCoreDataResult = activateCoreDataResult;
  }

  String getActivateCoreDataResult() {
    return _activateCoreDataResult;
  }

  void setLoginCoreDataResult(String loginCoreDataResult) {
    _loginCoreDataResult = loginCoreDataResult;
  }

  String getLoginCoreDataResult() {
    return _loginCoreDataResult;
  }

  void setLoanDetailsCoreDataResult(String loanDetailsCoreDataResult) {
    _loanDetailsCoreDataResult = loanDetailsCoreDataResult;
  }

  String getLoanDetailsCoreDataResult() {
    return _loanDetailsCoreDataResult;
  }

  void setApplicationCoreDataResult(String applicationCoreDataResult) {
    _applicationCoreDataResult = applicationCoreDataResult;
  }

  String getApplicationCoreDataResult() {
    return _applicationCoreDataResult;
  }

  void setReactivateCoreDataResult(String reactivateCoreDataResult) {
    _reactivateCoreDataResult = reactivateCoreDataResult;
  }

  String getReactivateCoreDataResult() {
    return _reactivateCoreDataResult;
  }

  void setIs401ReactivateResponse(int is401ReactivateResponse) {
    _is401ReactivateResponse = is401ReactivateResponse;
  }

  int getIs401ReactivateResponse() {
    return _is401ReactivateResponse;
  }

  void setIs400ReactivateResponse(int is400ReactivateResponse) {
    _is400ReactivateResponse = is400ReactivateResponse;
  }

  int getIs400ReactivateResponse() {
    return _is400ReactivateResponse;
  }

  void setIs200ResetPinStatusCode(int is200ResetPinStatusCode) {
    _is200ResetPinStatusCode = is200ResetPinStatusCode;
  }

  int getIs200ResetPinStatusCode() {
    return _is200ResetPinStatusCode;
  }

  void setIs401ResetPinResponse(int is401ResetPinResponse) {
    _is401ResetPinResponse = is401ResetPinResponse;
  }

  int getIs401ResetPinResponse() {
    return _is401ResetPinResponse;
  }

  void setIs400ResetPinResponse(int is400ResetPinResponse) {
    _is400ResetPinResponse = is400ResetPinResponse;
  }

  int getIs400ResetPinResponse() {
    return _is400ResetPinResponse;
  }

  void setEmailAddress(String emailAddress) {
    _emailAddress = emailAddress;
  }

  String getEmailAddress() {
    return _emailAddress;
  }

  void setIs400LoanApplicationUsingBio(int is400LoanApplicationUsingBio) {
    _is400LoanApplicationUsingBio = is400LoanApplicationUsingBio;
  }

  int getIs400LoanApplicationUsingBio() {
    return _is400LoanApplicationUsingBio;
  }

  void setIs401LoanApplicationUsingPin(int is401LoanApplicationUsingPin) {
    _is401LoanApplicationUsingPin = is401LoanApplicationUsingPin;
  }

  int getIs401LoanApplicationUsingPin() {
    return _is401LoanApplicationUsingPin;
  }

  void setIs400LoanApplicationUsingPin(int is400LoanApplicationUsingPin) {
    _is400LoanApplicationUsingPin = is400LoanApplicationUsingPin;
  }

  int getIs400LoanApplicationUsingPin() {
    return _is400LoanApplicationUsingPin;
  }

  void setIs401LoanApplicationUsingBio(int is401LoanApplicationUsingBio) {
    _is401LoanApplicationUsingBio = is401LoanApplicationUsingBio;
  }

  int getIs401LoanApplicationUsingBio() {
    return _is401LoanApplicationUsingBio;
  }

  void setIs200LoanApplicationUsingBio(int is200LoanApplicationUsingBio) {
    _is200LoanApplicationUsingBio = is200LoanApplicationUsingBio;
  }

  int getIs200LoanApplicationUsingBio() {
    return _is200LoanApplicationUsingBio;
  }

  void setIs200LoanApplicationUsingPin(int is200LoanApplicationUsingPin) {
    _is200LoanApplicationUsingPin = is200LoanApplicationUsingPin;
  }

  int getIs200LoanApplicationUsingPin() {
    return _is200LoanApplicationUsingPin;
  }

  void setDeviceId(String deviceId) {
    _deviceId = deviceId;
  }

  String getDeviceId() {
    return _deviceId;
  }

  void setRequestLoanCurrency(String requestLoanCurrency) {
    _requestLoanCurrency = requestLoanCurrency;
  }

  String getRequestLoanCurrency() {
    return _requestLoanCurrency;
  }

  void setLoanDetailsCurrency(String loanDetailsCurrency) {
    _loanDetailsCurrency = loanDetailsCurrency;
  }

  String getLoanDetailsCurrency() {
    return _loanDetailsCurrency;
  }

  void setDisplayLimit(String displayLimit) {
    _displayLimit = displayLimit;
  }

  String getDisplayLimit() {
    return _displayLimit;
  }

  void setConvertedLimitAmount(String convertedLimitAmount) {
    _convertedLimitAmount = convertedLimitAmount;
  }

  String getConvertedLimitAmount() {
    return _convertedLimitAmount;
  }

  void setUsdRate(String usdRate) {
    _usdRate = usdRate;
  }

  String getUsdRate() {
    return _usdRate;
  }

  void clearData() {
    _coreDataResult = '';
    _appId = '';
    _customerId = '';
    _userStatus = '';
    _is401ActivationResponse = 0;
    _is400ActivationResponse = 0;
    _mobileNumber = '';
    _limitAmount = '';
    _displayLimit = '';
    _limitMessage = '';
    _loanTermPeriod = '';
    _interestRate = '';
    _is401LoginResponse = 0;
    _is400LoginResponse = 0;
    _firstName = '';
    _loanCurrency = '';
    _requestLoanAmount = '';
    _loanId = '';
    _lastName = '';
    _totalOutstanding = '';
    _pastDueDays = '';
    _totalPrincipalDisbursed = '';
    _loanDetailsId = '';
    _loanDetailsInterestRate = '';
    _principal = '';
    _totalPrincipalExpected = '';
    _totalRepaymentExpected = '';
    _loanTransactionAmount = '';
    _loanTransactionDate = '';
    _loanTransactionBalance = '';
    _loanTransactionReceiptNumber = '';
    // _loanTransactions = [];
    // _loanDetails = [];
    _loanTransactionId = '';
    _loginLoanId = '';
    _is401LoanDetailsResponse = 0;
    _is400LoanDetailsResponse = 0;
    _loanTransactionType = '';
    _loginCoreDataResult = '';
    _loanDetailsCoreDataResult = '';
    _applicationCoreDataResult = '';
    _activateCoreDataResult = '';
    _reactivateCoreDataResult = '';
    _is401ReactivateResponse = 0;
    _is400ReactivateResponse = 0;
    _is200ResetPinStatusCode = 0;
    _is401ResetPinResponse = 0;
    _is400ResetPinResponse = 0;
    _emailAddress = '';
    _is400LoanApplicationUsingBio = 0;
    _is401LoanApplicationUsingPin = 0;
    _is400LoanApplicationUsingPin = 0;
    _is401LoanApplicationUsingBio = 0;
    _is200LoanApplicationUsingBio = 0;
    _is200LoanApplicationUsingPin = 0;
    _requestLoanCurrency = '';
    _loanDetailsCurrency = '';
    _convertedLimitAmount = '';
    _usdRate = '';
  }

  void clearDataOnInactivityLogout() {
    _is401ActivationResponse = 0;
    _is400ActivationResponse = 0;
    _limitAmount = '';
    _displayLimit = '';
    _limitMessage = '';
    _loanTermPeriod = '';
    _interestRate = '';
    _is401LoginResponse = 0;
    _is400LoginResponse = 0;
    _firstName = '';
    _loanCurrency = '';
    _requestLoanAmount = '';
    _loanId = '';
    _lastName = '';
    _totalOutstanding = '';
    _pastDueDays = '';
    _totalPrincipalDisbursed = '';
    _loanDetailsId = '';
    _loanDetailsInterestRate = '';
    _principal = '';
    _totalPrincipalExpected = '';
    _totalRepaymentExpected = '';
    _loanTransactionAmount = '';
    _loanTransactionDate = '';
    _loanTransactionBalance = '';
    _loanTransactionReceiptNumber = '';
    // _loanTransactions = [];
    // _loanDetails = [];
    _loanTransactionId = '';
    _loginLoanId = '';
    _is401LoanDetailsResponse = 0;
    _is400LoanDetailsResponse = 0;
    _loanTransactionType = '';
    _loginCoreDataResult = '';
    _loanDetailsCoreDataResult = '';
    _applicationCoreDataResult = '';
    _activateCoreDataResult = '';
    _reactivateCoreDataResult = '';
    _is401ReactivateResponse = 0;
    _is400ReactivateResponse = 0;
    _is200ResetPinStatusCode = 0;
    _is401ResetPinResponse = 0;
    _is400ResetPinResponse = 0;
    _emailAddress = '';
    _is400LoanApplicationUsingBio = 0;
    _is401LoanApplicationUsingPin = 0;
    _is400LoanApplicationUsingPin = 0;
    _is401LoanApplicationUsingBio = 0;
    _is200LoanApplicationUsingBio = 0;
    _is200LoanApplicationUsingPin = 0;
    _requestLoanCurrency = '';
    _loanDetailsCurrency = '';
    _convertedLimitAmount = '';
    _usdRate = '';
  }
}
