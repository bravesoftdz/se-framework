local module_login = {};

function module_login:showme()	
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Login_OnClickClose,     fol.login.doClose);
	fol.listen:register(self, fol.msgcode.Login_OnClickLogin,     fol.login.doLogin);
	fol.listen:register(self, fol.msgcode.Login_OnClickRegister,  fol.login.doRegister);
	
	fol.listen:register(self, fol.netmsgcode.MSG_Login_Login_r,   fol.login.doLogin_r);
	
	--ע�����¼�
	fol.uipkg:registerClickEvent("frmLogin", "btnClose",          fol.msgcode.Login_OnClickClose);
	fol.uipkg:registerClickEvent("frmLogin", "btnLogin",          fol.msgcode.Login_OnClickLogin);
	fol.uipkg:registerClickEvent("frmLogin", "btnRegister",       fol.msgcode.Login_OnClickRegister);
	
    --��ʾ��¼����
	fol.uipkg:showWindow("frmLogin");
end

function module_login:doClose()
	--�رյ�¼����
	fol.uipkg:closeWindow("frmLogin");
end

function module_login:doLogin()	
	--���͵�¼����
	fol.netcmd:login_login("test", "654321");	
end

function module_login:doRegister()
	--��ת��ע��ģ��
	fol.register:showme();
end

function module_login:doLogin_r(data)
	--��¼�������Ӧ
	if data.result == true then
		fol.login:doClose();
	else
		OutputDebugString("login fail...");
	end
	--
	
	OutputDebugString(data.data);
end

return module_login;