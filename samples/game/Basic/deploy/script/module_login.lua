local module_login = {};

function module_login:showme()
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Login_OnLogin,  fol.login.doLogin);
	--ע�����¼�
	fol.uipackage:registerClickEvent("frmLogin", "btnLogin",  fol.msgcode.Login_OnLogin);
	
	fol.uipackage:showWindow("frmLogin");
end

function module_login:doLogin()
	--�ر�
	fol.uipackage:closeWindow("frmLogin");
end

return module_login;