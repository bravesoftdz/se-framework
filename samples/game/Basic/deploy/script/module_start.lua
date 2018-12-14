local module_start = {};

function module_start:init()
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Start_OnClickChangeRole,    fol.start.doChangeRole);
	fol.listen:register(self, fol.msgcode.Start_OnClickStart,         fol.start.doStart);
	
	fol.listen:register(self, fol.netmsgcode.MSG_Start_Login_r,       fol.start.doStart_r);

	--ע�����¼�
	fol.uipkg:registerClickEvent("MainForm", "start_btnChangeRole",   fol.msgcode.Start_OnClickChangeRole);
	fol.uipkg:registerClickEvent("MainForm", "start_btnStart",        fol.msgcode.Start_OnClickStart);

	--���ű�������
	fol.soundpkg:play("background.mp3");
end

function module_start:doChangeRole()
	--��ʾ��¼����
	fol.login:showme();
end

function module_start:doStart()
	fol.netcmd:start_login("test", "7c4a8d09ca3762af61e59520943dc26494f8941b");
end

function module_start:doStart_r(data)
	if data.result == true then
		fol.uipkg:switchScene("main");
		OutputDebugString("login success...");
	else
		OutputDebugString("login fail...");
	end
	--
	OutputDebugString(data.data);
end

return module_start;