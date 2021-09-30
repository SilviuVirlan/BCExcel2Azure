page 70000 "Custom Setup.FQ"
{

    Caption = 'Custom Setup';
    PageType = Card;
    SourceTable = "Cutom Setup.FQ";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(Azure)
            {
                field("Account URL"; Rec."Account URL.FQ")
                {
                    ToolTip = 'Specifies the value of the Account URL field';
                    ApplicationArea = All;
                }
                field(Container; Rec."Container.FQ")
                {
                    ToolTip = 'Specifies the value of the Container Name field';
                    ApplicationArea = All;
                }
                field("SAS Token"; Rec."SAS Token.FQ")
                {
                    ToolTip = 'Specifies the value of the SAS Token field';
                    ApplicationArea = All;
                }
            }
            group(Options)
            {
                field("Only G/L Accounts with balance"; Rec."Only G/L Acc. with balance.FQ")
                {
                    ApplicationArea = All;
                    Tooltip = 'Show only G/L Accounts with non-zero balance';
                }
                field("Extract Open Bal. for period"; Rec."Extr. Open Bal. for period.FQ")
                {
                    ApplicationArea = All;
                    Tooltip = 'Extract Open Bal. for period';
                }
                field("Extract Net Change for period"; Rec."Extr. Net Change for period.FQ")
                {
                    ApplicationArea = All;
                    Tooltip = 'Extract Net Change for period';
                }
            }
        }
    }
}