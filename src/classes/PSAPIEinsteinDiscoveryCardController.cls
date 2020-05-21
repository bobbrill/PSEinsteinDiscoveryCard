public class PSAPIEinsteinDiscoveryCardController {
    @AuraEnabled
    public static String getEDInfo(String params)
    {
        System.debug('getEDInfo invoked...');
        System.debug('params=' + params);
        Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);
        PSAPIResponse resp = new PSAPIResponse();
        
        try
        {

            String recId = paramMap.get('recId');
            String predDefId = paramMap.get('predDefId');
            
            ConnectApi.SmartDataDiscoveryPredictInputRecords inputRep = new ConnectApi.SmartDataDiscoveryPredictInputRecords();
            inputRep.records = new list<string>{recId};
        	inputRep.predictionDefinition = predDefId;
        
        	// using the connect api here - could be REST just as easilly
            ConnectApi.SmartDataDiscoveryPrediction predOut;
            
            if(!Test.isRunningTest())
            {
                 predOut = ConnectApi.SmartDataDiscovery.predict(inputRep);    
            }
            else
            {
                 predOut = generateMockPredictionForTest();
            }
            
            
            Map<String, Object>respMap = new Map<String, Object>();
            respMap.put('prediction', getPrediction((ConnectApi.SmartDataDiscoveryPredictObject) predOut.predictions[0]));
            respMap.put('reasons', getReasons((ConnectApi.SmartDataDiscoveryPredictObject) predOut.predictions[0], paramMap.get('section1Limit')));
            respMap.put('prescriptions', getPrescriptions(((ConnectApi.SmartDataDiscoveryPredictObject)predOut.predictions[0]).prescriptions, paramMap.get('section2Limit'),(ConnectApi.SmartDataDiscoveryPredictObject) predOut.predictions[0]));
             
             
            resp.data = respMap;
        }
        catch (exception e)
        {
            resp.status = PSAPIResponse.ERROR;
            resp.msg = e.getMessage();
        }
        
        return  JSON.serialize(resp);
    }
    
    private static String getPrescriptions(List<ConnectApi.SmartDataDiscoveryPredictCondition> conditions, String lim, ConnectApi.SmartDataDiscoveryPredictObject prediction) {
        Integer limInt = lim != null ? Integer.valueOf(lim) : null;
        
        // expected string output:
    	//	+10.398 if you change Owner_Name__c to Deeann Alvidrez
    	//	+9.344 if you change Owner_Name__c to Rebecca Streets
    	//	+8.792 if you change Owner_Name__c to Meda Buskey
    	//	+7.701 if you change Owner_Name__c to Marcelina Gahan
    	//	+7.533 if you change Owner_Name__c to Mignon Redick
    	//	+6.752 if you change Owner_Name__c to Hugh Moloney
    	//	+5.832 if you change Owner_Name__c to Alysha Siebert
    	//	+4.779 if you change Owner_Name__c to Alicia Mantyla
    	//	+4.547 if you change Owner_Name__c to Tobias Hudson
    	//	+4.116 if you change Owner_Name__c to Hollis Litz
    	String prescriptions = '';
    	
        Integer numPrescriptions = 0;
		for (ConnectApi.SmartDataDiscoveryPredictCondition condition : conditions) {
			if (numPrescriptions > 0) {
				prescriptions += '\n';
			} 
			
			prescriptions += makeNumberStr(condition.value);
			prescriptions += ' if you change ';
			prescriptions += condition.columns.get(0).columnName;
			prescriptions += ' to '; 
			prescriptions += condition.columns.get(0).columnValue;
			
			if (condition.columns.size() > 1) {
				prescriptions += ' and ';
				prescriptions += condition.columns.get(1).columnName;
				prescriptions += ' to '; 
				prescriptions += condition.columns.get(1).columnValue;
			}
			
			numPrescriptions++;
			if (limInt != null && limInt > 0 && limInt <= numPrescriptions) {
				break;
			}
		}
		
		return prescriptions;
    }
    
    private static Double getPrediction(ConnectApi.SmartDataDiscoveryPredictObject prediction) {
        return prediction.prediction.total;
    }
    
     private static String getReasons(ConnectApi.SmartDataDiscoveryPredictObject prediction, String lim) {
    	Integer limInt = lim != null ? Integer.valueOf(lim) : null;
        
        // expected string output:
    	//	+1.546 because requestor__c is 1400 to 1600 and Priority__c is 0 - Unassigned
		//	+1.264 because TicketType__c is Request and Severity__c is 4 - Critical
		//	-1.107 because requestor__c is 1400 to 1600 and Owner_Name__c is Tianna Bryden
		//	-0.205 because of other factors
		//	from the baseline, +46.233
		String reasons = '';
		
		Integer numReasons = 0;
		for (ConnectApi.SmartDataDiscoveryPredictCondition midVal : prediction.prediction.middleValues) {
			if (numReasons > 0) {
				reasons += '\n';
			}
			
			reasons += makeNumberStr(midVal.value);
			reasons += ' because ';
			reasons += midVal.columns.get(0).columnName;
			reasons += ' is '; 
			reasons += midVal.columns.get(0).columnValue;
			
			if (midVal.columns.size() > 1) {
				reasons += ' and ';
				reasons += midVal.columns.get(1).columnName;
				reasons += ' is '; 
				reasons += midVal.columns.get(1).columnValue;
			}
			
			numReasons++;
			if (limInt != null && limInt > 0 && limInt <= numReasons) {
				break;
			}
		}
		
		// always include other and baseline
    	if (prediction.prediction.other != null && prediction.prediction.other != 0) {
    		reasons += '\n';
    		reasons += makeNumberStr(prediction.prediction.other);
    		reasons += ' because of other factors';
    	}
    	
    	if (prediction.prediction.baseLine != null && prediction.prediction.baseLine != 0) {
    		reasons += '\n';
    		reasons += makeNumberStr(prediction.prediction.baseLine);
    		reasons += ' from the baseline';
    	}
    	
    	return reasons;
    }
    
    private static String makeNumberStr(Double num) {
    	String out = '';
    	if (num >= 0) {
			out += '+ ';
		} else {
			out += '- ';
		}
		
		out += String.valueOf(math.abs(num));
		
    	return out;
    }
    public static ConnectApi.SmartDataDiscoveryPrediction generateMockPredictionForTest()
    {
        ConnectApi.SmartDataDiscoveryPrediction predictions = new ConnectApi.SmartDataDiscoveryPrediction();
        ConnectApi.SmartDataDiscoveryPredictObject prediction = new ConnectApi.SmartDataDiscoveryPredictObject();
        ConnectApi.SmartDataDiscoveryPredict predictionValue = new ConnectApi.SmartDataDiscoveryPredict();
        ConnectApi.SmartDataDiscoveryPredictCondition commentary = new ConnectApi.SmartDataDiscoveryPredictCondition();
        ConnectApi.SmartDataDiscoveryPredictColumn column = new ConnectApi.SmartDataDiscoveryPredictColumn();
        ConnectApi.SmartDataDiscoveryPredictColumn recommendationcolumn = new ConnectApi.SmartDataDiscoveryPredictColumn();
        ConnectApi.SmartDataDiscoveryPredictCondition Recommendations = new ConnectApi.SmartDataDiscoveryPredictCondition();
        
        //Recomendation fake data
        Recommendations.value = 6;
        recommendationcolumn.columnName = 'TestColumn';
        recommendationcolumn.columnValue = 'Test2';
        Recommendations.columns = new List<ConnectApi.SmartDataDiscoveryPredictColumn>();
        Recommendations.columns.add(recommendationcolumn);
        
        //Commentary fake data
        column.columnName = 'testcolumn';
        column.columnValue = 'test';
        commentary.value = 3;
        commentary.columns = new List<ConnectApi.SmartDataDiscoveryPredictColumn>();
        commentary.columns.add(column);
		
        //Fake prediction value
        predictionValue.total = 6;
        predictionValue.other = 10;
        predictionValue.baseLine = 4;
        predictionValue.middleValues = new list<ConnectApi.SmartDataDiscoveryPredictCondition>();
        predictionValue.middleValues.add(commentary);
      
        
        //Fake Predction object
        prediction.prediction = predictionValue;
        prediction.prescriptions = new list<ConnectApi.SmartDataDiscoveryPredictCondition>();
        prediction.prescriptions.add(Recommendations);

        //Fake list of predictions
        predictions.predictions = new list<ConnectApi.SmartDataDiscoveryPredictObject>();
        predictions.predictions.add(prediction);
        
        return predictions;
    }
}