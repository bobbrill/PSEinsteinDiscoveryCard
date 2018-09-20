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
            
            ConnectApi.SmartDataDiscoveryPredictInput inputRep = new ConnectApi.SmartDataDiscoveryPredictInput();
            inputRep.entityId = recId;
        	inputRep.predictionDefinitionId = predDefId;
        
        	// using the connect api here - could be REST just as easilly
            ConnectApi.SmartDataDiscoveryPrediction predOut = ConnectApi.SmartDataDiscovery.predict(inputRep);
            
            Map<String, Object>respMap = new Map<String, Object>();
            respMap.put('prediction', getPrediction(predOut.prediction));
            respMap.put('reasons', getReasons(predOut.prediction));
            respMap.put('prescriptions', getPrescriptions(predOut.prescriptions));
             
            resp.data = respMap;
        }
        catch (exception e)
        {
            resp.status = PSAPIResponse.ERROR;
            resp.msg = e.getMessage();
        }
        
        return  JSON.serialize(resp);
    }
    
    private static String getPrescriptions(List<ConnectApi.SmartDataDiscoveryPredictCondition> conditions) {
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
    	
        boolean skipReturn = true;
		for (ConnectApi.SmartDataDiscoveryPredictCondition condition : conditions) {
			if (!skipReturn) {
				prescriptions += '\n';
			} else {
				skipReturn = false;
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
		}
		
		return prescriptions;
    }
    
    private static Double getPrediction(ConnectApi.SmartDataDiscoveryPredict prediction) {
        return prediction.total;
    }
    
    private static String getReasons(ConnectApi.SmartDataDiscoveryPredict prediction) {
    	// expected string output:
    	//	+1.546 because requestor__c is 1400 to 1600 and Priority__c is 0 - Unassigned
		//	+1.264 because TicketType__c is Request and Severity__c is 4 - Critical
		//	-1.107 because requestor__c is 1400 to 1600 and Owner_Name__c is Tianna Bryden
		//	-0.205 because of other factors
		//	from the baseline, +46.233
		String reasons = '';
		
		boolean skipReturn = true;
		for (ConnectApi.SmartDataDiscoveryPredictCondition midVal : prediction.middleValues) {
			if (!skipReturn) {
				reasons += '\n';
			} else {
				skipReturn = false;
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
		}
		
    	if (prediction.other != null && prediction.other != 0) {
    		reasons += '\n';
    		reasons += makeNumberStr(prediction.other);
    		reasons += ' because of other factors';
    	}
    	
    	if (prediction.baseLine != null && prediction.baseLine != 0) {
    		reasons += '\n';
    		reasons += makeNumberStr(prediction.baseLine);
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
    	out += math.abs(num).format();
    	
    	return out;
    }
}