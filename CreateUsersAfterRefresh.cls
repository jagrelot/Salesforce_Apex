global class CreateUsersAfterRefresh implements SandboxPostCopy
{
    global void runApexClass(SandboxContext context) 
    {        
    Set<User> teamMemmberUsers = new Set<User>([SELECT Id, Email 
                                                FROM User 
                                                WHERE Training_Team_Member__c = true
                                                AND IsActive = true]);     
    Map<Id, User> idUserMap = new Map<Id, User>();
    
    User[] updatedUsers = new User[0];
     
    for(User u : teamMemmberUsers)
    { 
       idUserMap.put(u.id, u);
    }
        
    for(User u : idUserMap.values())
    {  
       String invalidRemoved = u.Email.remove('.invalid');
       u.Email = invalidRemoved;
    }
       updatedUsers.addAll(idUserMap.values());
        
    List<User> newUsers = new List<User>();
    Id adminProfileID = [Select Id, name 
                         From Profile 
                         WHERE name = 'System Administrator'].Id;
        
     for(New_User__mdt u_mdt :[SELECT Id, MasterLabel,Training_Team_Member__c 
                               FROM New_User__mdt
                               WHERE Training_Team_Member__c = false])
     {
          List<String> labelName = u_mdt.MasterLabel.split(' ');
        	String firstName = labelName[0];
        	String lastName  = labelName[1];
         	String name      = firstName + ' ' + lastName;
        	String domain	 = '@acumensolutions.com';
        	String email     = firstName.substring(0,1) + lastName + domain;
        	String alias	 = firstName.substring(0,1) + lastName.substring(0,3);
        	String nickname  = firstName + ' ' + lastName.substring(0,1);
         
     	    User u = new User();
     	    u.isActive  = true;
     	    u.FirstName = firstName;
     	    u.LastName  = lastName;
     	    u.Email 	   = email;
	        u.Username  = email + '.' + context.sandboxName();
          u.Alias     = alias;
          u.CommunityNickname  = nickname;
     	    u.LocaleSidKey   = 'en_US';
		      u.TimeZoneSidKey = 'GMT';
		      u.ProfileID      = adminProfileID;
		      u.LanguageLocaleKey = 'en_US';
		      u.EmailEncodingKey  = 'UTF-8';
       	  newUsers.add(u);
     }
        	updatedUsers.addAll(newUsers);
        	Database.upsert(updatedUsers);
        	resetPasswordforUsers(updatedUsers);
 	}
  
    public void resetPasswordforUsers(List<User> users)
    {
        for(User u : users)
        {
            System.resetPassword(u.Id, true);
        }
    }
}
