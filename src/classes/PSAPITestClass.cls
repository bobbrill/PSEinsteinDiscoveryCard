@isTest (SeeAllData=true)
public class PSAPITestClass {
 	@isTest
    static void TestLoadController()
    {

        String result = PSAPIEinsteinDiscoveryCardController.getEDInfo('{"recId":"'+UserInfo.getUserId()+'","outcomeField":"Name", "section1Field":"Username", "section2Field":"email"}');
		
        result = PSAPIEinsteinDiscoveryCardController.getEDInfo('{"recId":"'+UserInfo.getUserId()+'","outcomeField":"Id", "section1Field":"Username", "section2Field":"email"}');

    }
}