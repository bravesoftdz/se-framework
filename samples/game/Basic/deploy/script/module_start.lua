local module_start = {};

function module_start:init()
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Start_OnClickShowLogin,     fol.start.showLogin);
	fol.listen:register(self, fol.msgcode.Start_OnClickShowRank,      fol.start.showRank);
	--ע�����¼�
	fol.uipackage:registerClickEvent("MainForm", "btnShowLogin",      fol.msgcode.Start_OnClickShowLogin);
	fol.uipackage:registerClickEvent("MainForm", "btnShowRank",       fol.msgcode.Start_OnClickShowRank);
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