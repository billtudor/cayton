component {
	// copied from AWS Java sample as an example of a 'backoff algorithm'. nb: 3,600,000ms = 1hr (we don't wnat a thread waiting too long!)
	variables.constants.Results = {
		"FAIL"=-1
		,"SUCCESS"=0
		,"NOT_READY"=-1
		,"THROTTLED"=2
		,"SERVER_ERROR"=4
		,"MAX_WAIT_INTERVAL"=3600000
		,"MAX_RETRIES"=100
		,"UNKNOWN_ERROR"=9
	};
	
	public numeric function calcTimeRetry(required numeric retries){
	
		return min( getWaitTimeExp(retries), variables.constants.Results.MAX_WAIT_INTERVAL);
	}
	
	/*
	 * Performs an asynchronous operation, then polls for the result of the
	 * operation using an incremental delay.
	*/
	public array function doOperationAndWaitForResult(MAX_RETRIES) {

		try {
			// Do some asynchronous operation.
			var token = asyncOperation();
			var retries = 0;
			var retry = true;
			var attempts = [];
			var result = variables.constants.Results.FAIL;

			while (retry AND (retries++ LT arguments.MAX_RETRIES)) {
			
				var waitTime = min( getWaitTimeExp(retries), variables.constants.Results.MAX_WAIT_INTERVAL);

				sleep(waitTime);

				// Get the result of the asynchronous operation.
				var result = getAsyncOperationResult(token);

				if (result EQ variables.constants.Results.SUCCESS) {
					retry = false;
				} else if (result EQ variables.constants.Results.NOT_READY) {
					retry = true;
				} else if (result EQ variables.constants.Results.THROTTLED) {
					retry = true;
				} else if (result EQ variables.constants.Results.SERVER_ERROR) {
					retry = true;
				}
				else {
					// Some other error occurred, so stop calling the API.
					retry = false;
				}
				
				attempts.append({tokenUuid=token, RequestTime=Now(), errorCode=result});
			}

		} catch (Exception ex) {
			attempts.append({tokenUuid=token, RequestTime=Now(), errorCode=result});
		}

		// TODO: we may need to add retry time and token as a structure to attempts array
		return attempts;
	}

	/*
	 * Returns the next wait interval, in milliseconds, using a very simple exponential backoff algorithm.
	*/ 
	private function getWaitTimeExp(numeric retryCount) {

		var waitTime = (retryCount^2) * 1000;

		return waitTime;
	}

	private function getAsyncOperationResult(){
		// mock this for testing to return all possible results
		return variables.constants.Results.SUCCESS;
	}

	private function asyncOperation(){
		
		return createUUID();
	}
 
}