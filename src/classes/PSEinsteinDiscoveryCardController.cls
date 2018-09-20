public class PSEinsteinDiscoveryCardController {
    @AuraEnabled
    public static String getEDInfo(String params)
    {
        System.debug('getEDInfo invoked...');
        System.debug('params=' + params);
        Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);
        PSResponse resp = new PSResponse();
        
        try
        {
            String recId = paramMap.get('recId');
            String predDefId = paramMap.get('predDefId');
            
            ConnectApi.SmartDataDiscoveryPredictInput inputRep = new ConnectApi.SmartDataDiscoveryPredictInput();
            inputRep.setEntityId(recId);
        	inputRep.setPredictionDefinitionId(predDefId);
        
        	// using the connect api here - could be REST just as easilly
            ConnectApi.SmartDataDiscoveryPrediction predition = ConnectApi.SmartDataDiscovery.predict(inputRep);
            
            Map<String, Object>respMap = new Map<String, Object>();
            respMap.put("prediction", getPrediction(predition.getPrediction()));
            respMap.put("reasons", getReasons(predition.getPrediction()));
            respMap.put("prescriptions", getPrescription(predition.getPrescriptions()));
             
            resp.data = respMap;
        }
        catch (exception e)
        {
            resp.status = PSResponse.ERROR;
            resp.msg = e.getMessage();
        }
        
        return  JSON.serialize(resp);
    }
    
    private static String serializePrescriptions(List<SmartDataDiscoveryPredictConditionRepresentation> conditions) {
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
				prescriptions = false;
			}
			
			prescriptions += makeNumberStr(condition.getValue());
			prescriptions += ' if you change ';
			prescriptions += condition.getColumns().get(0).getColumnName();
			prescriptions += ' to '; 
			prescriptions += condition.getColumns().get(0).getColumnValue();
			
			if (condition.getColumns().size() > 1) {
				prescriptions += ' and ';
				prescriptions += condition.getColumns().get(1).getColumnName();
				prescriptions += ' to '; 
				prescriptions += condition.getColumns().get(1).getColumnValue();
			}
		}
		
		return prescriptions;
    }
    
    private static Double getPrediction(ConnectApi.SmartDataDiscoveryPredict prediction) {
        return prediction.getTotal();
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
		for (ConnectApi.SmartDataDiscoveryPredictCondition midVal : prediction.getMiddleValues()) {
			if (!skipReturn) {
				reasons += '\n';
			} else {
				skipReturn = false;
			}
			
			reasons += makeNumberStr(midVal.getValue());
			reasons += ' because ';
			reasons += midVal.getColumns().get(0).getColumnName();
			reasons += ' is '; 
			reasons += midVal.getColumns().get(0).getColumnValue();
			
			if (midVal.getColumns().size() > 1) {
				reasons += ' and ';
				reasons += midVal.getColumns().get(1).getColumnName();
				reasons += ' is '; 
				reasons += midVal.getColumns().get(1).getColumnValue();
			}
		}
		
    	if (prediction.getOther() != null && prediction.getOther() != 0) {
    		reasons += '\n';
    		reasons += makeNumberStr(prediction.getOther());
    		reasons += ' because of other factors';
    	}
    	
    	if (prediction.getBaseLine() != null && prediction.getBaseLine() != 0) {
    		reasons += '\nfrom baseline, ';
    		reasons += makeNumberStr(prediction.getBaseLine());
    	}
    	
    	return reasons;
    }
    
    private String makeNumberStr(Doublt num) {
    	String out = '';
    	if (num >= 0) {
			out += '+ ';
		} else {
			out += '- ';
		}
    	out += num;
    	
    	return out;
    }
}