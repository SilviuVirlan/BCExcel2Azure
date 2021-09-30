pageextension 70000 "Bus. Mgr. RC Ext.FQ" extends "Business Manager Role Center"
{
    actions
    {
        addafter(Deposits)
        {
            action(TrialBalRuns)
            {
                ApplicationArea = All;
                Caption = 'Trial Balance Runs**';
                RunObject = Page "Trial Balance Runs.FQ";
                ToolTip = 'Trial Balance Runs';
            }
        }
    }
}