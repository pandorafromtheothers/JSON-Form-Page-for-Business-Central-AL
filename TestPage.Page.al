page 50281 TestPage
{
    ApplicationArea = All;
    Caption = 'Test Page For Generic';
    PageType = Card;
    SourceTable = "Integer";
    UsageCategory = Administration;
    SourceTableTemporary = true;
    SourceTableView = where(Number = const(1));


    layout
    {
        area(Content)
        {
            field(JSON; 'Test')
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    _base, _request : JsonObject;
                    _p: Page "Generic Page";
                begin
                    _base := MAIN();
                    if _p.MakeJSONObjectWithTokenSelectionPage(_base, _request) then begin
                        Message(Format(_request));
                    end;
                end;
            }
            field(FORM; 'Test')
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    _p: Page "Generic Page";
                begin
                    Clear(_p);
                    _p.SetVisibile('Your Input', '');
                    _p.LookupMode(true);
                    if _p.RunModal() <> Action::LookupOK then
                        exit;

                    Message(_p.GetPageValue('').AsText());
                end;
            }

        }
    }

    local procedure MAIN() result: JsonObject
    begin
        result := BasicInformation();
        result.Add('Siblings', Siblings());
    end;


    local procedure BasicInformation() result: JsonObject
    begin
        result.Add('Cat', G.DefaultValue(FieldType::Boolean));
        result.Add('BornDate', G.DefaultValue(FieldType::Date));
        result.Add('Food_Opinions', FoodOpinions());
    end;

    local procedure FoodOpinions() result: JsonObject
    begin
        result.Add('Best_Food', G.DefaultValue(FieldType::Text));
        result.Add('Worst_Food', G.DefaultValue(FieldType::Text));
    end;

    procedure Siblings() result: JsonArray
    begin
        result.Add(BasicInformation());
    end;

    var
        G: Page "Generic Page";
}