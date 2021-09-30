table 70000 "Cutom Setup.FQ"
{
    Caption = 'Custom Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; PK; Code[1])
        {
            Caption = 'PK';
            DataClassification = SystemMetadata;
        }
        field(2; "Account URL.FQ"; Text[250])
        {
            Caption = 'Account URL';
            DataClassification = SystemMetadata;
        }
        field(3; "SAS Token.FQ"; Text[250])
        {
            Caption = 'SAS Token';
            DataClassification = SystemMetadata;
        }
        field(4; "Container.FQ"; Text[250])
        {
            Caption = 'Container Name';
            DataClassification = SystemMetadata;
        }
        field(10; "Only G/L Acc. with balance.FQ"; Boolean)
        {
            Caption = 'Only G/L Accounts with balance';
            DataClassification = SystemMetadata;
        }
        field(11; "Extr. Open Bal. for period.FQ"; Boolean)
        {
            Caption = 'Extract Open Bal. for period';
            DataClassification = SystemMetadata;
        }
        field(12; "Extr. Net Change for period.FQ"; Boolean)
        {
            Caption = 'Extract Net Change for period';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }
}
