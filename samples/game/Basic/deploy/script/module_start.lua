local module_start = {};

function module_start:init()
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Start_OnClickShowLogin,     fol.start.showLogin);
	fol.listen:register(self, fol.msgcode.Start_OnClickShowRank,      fol.start.showRank);
	--ע�����¼�
	fol.uipkg:registerClickEvent("MainForm", "btnShowLogin",      fol.msgcode.Start_OnClickShowLogin);
	fol.uipkg:registerClickEvent("MainForm", "btnShowRank",       fol.msgcode.Start_OnClickShowRank);
	--���ű�������
	fol.soundpkg:play("background.mp3");
end

function module_start:showLogin()
	--��ʾ��¼����
	fol.login:showme();
end

function module_start:showRank()
	--��ʾ���д���
	fol.rank:showme();
end

return module_start;