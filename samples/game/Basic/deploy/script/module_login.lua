local module_login = {};

function module_login:showme()	
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Login_OnLogin,  fol.login.doLogin);
	--ע�����¼�
	fol.uipkg:registerClickEvent("frmLogin", "btnLogin",  fol.msgcode.Login_OnLogin);
    --��ʾ
	fol.uipkg:showWindow("frmLogin");
end

function module_login:doLogin()
	--�ر�
	fol.uipkg:closeWindow("frmLogin");
end

return module_login;