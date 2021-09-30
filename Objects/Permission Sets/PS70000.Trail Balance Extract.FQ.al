permissionset 70000 "Trial Bal. Extr.FQ"
{
    Assignable = true;
    Caption = 'Trial Balance Wrapper PSET';
    Permissions =
        tabledata "Cutom Setup.FQ" = RIMD,
        tabledata "Trial Balance Run.FQ" = RIMD;
}