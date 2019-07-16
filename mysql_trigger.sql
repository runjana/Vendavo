-----------------// update trigger //------------------------

DELIMITER //
CREATE TRIGGER after_PASSWORD_update AFTER UPDATE ON BANKSMART.APPLICATION_USER 
FOR EACH ROW
BEGIN 
  UPDATE REPORT.REPORT_USER
  SET USERNAME = NEW.USERNAME
  WHERE NAME = new.name;
  
   UPDATE REPORT.REPORT_USER
  SET PASSWORD = NEW.PASSWORD
  WHERE NAME = new.name;
   
END //
DELIMITER ;

-------------------------------------------------------------