local module_register = {};

function module_register:showme()	
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Register_OnClickClose,     fol.register.doClose);
	fol.listen:register(self, fol.msgcode.Register_OnClickRegister,  fol.register.doRegister);
	
	fol.listen:register(self, fol.netmsgcode.MSG_Register_Register_r,fol.start.doRegister_r);
	
	--ע�����¼�
	fol.uipkg:registerClickEvent("frmRegister", "btnClose",          fol.msgcode.Register_OnClickClose);
	fol.uipkg:registerClickEvent("frmRegister", "btnRegister",       fol.msgcode.Register_OnClickRegister);
	
    --��ʾע�ᴰ��
	fol.uipkg:showWindow("frmRegister");
end

function module_register:doClose()
	--�ر�ע�ᴰ��
	fol.uipkg:closeWindow("frmRegister");
end

function module_register:doRegister()
	--����ע������
	fol.netcmd:register("13800591505", "123456");
end

function module_register:doRegister_r(data)
	--ע���������Ӧ
	if data.result == true then
		OutputDebugString("register success...");
	else
		OutputDebugString("register fail...");
	end
	--
	OutputDebugString(data.data);
end

return module_register;