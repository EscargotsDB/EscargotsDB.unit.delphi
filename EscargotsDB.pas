unit EscargotsDB;

interface

uses
  System.SysUtils,IdHTTP,System.JSON,System.Classes,Vcl.Dialogs;

  type TeDB = class
  private
    Fport: string;
    Fhost: string;
    Fdebug: Boolean;
    procedure Sethost(const Value: string);
    procedure Setport(const Value: string);
    procedure Setdebug(const Value: Boolean);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    property host:string read Fhost write Sethost;
    property port:string read Fport write Setport;
    property debug:Boolean read Fdebug write Setdebug;
    function _set_(collection,key:string; payload: TStringStream):boolean;
    function _get_(collection,key:string):TJSONObject;
    function _del_(collection,key:string):boolean;
    function get_list(listName,collection:string):TJSONArray;
    function send_list(listName,collection,key:string):Boolean;
  published
    { published declarations }
  end;

implementation

{ TeDB }

function TeDB.get_list(listName, collection: string): TJSONArray;
var
lHTTP : TIdHTTP;
objeto: TJSONArray;
_result:string;
json:string;
begin
     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/get/list?name='+listName+'&collection='+collection);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONArray;

       Result := objeto;

     finally
       lHTTP.Free;
     end;

end;

function TeDB.send_list(listName, collection, key: string): Boolean;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
begin

     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/send/list?name='+listName+'&collection='+collection+'&key='+key);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Result := False;
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := True;
       end else begin
         Result := False;
       end;

     finally
       lHTTP.Free;
     end;

end;

procedure TeDB.Setdebug(const Value: Boolean);
begin
  Fdebug := Value;
end;

procedure TeDB.Sethost(const Value: string);
begin
  Fhost := Value;
end;

procedure TeDB.Setport(const Value: string);
begin
  Fport := Value;
end;

function TeDB._del_(collection, key: string): boolean;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
begin
     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/del?key='+key+'&collection='+collection);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := True;
       end else begin
         Result := False;
       end;

     finally
       lHTTP.Free;
     end;

end;

function TeDB._get_(collection, key: string): TJSONObject;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
begin
     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/get?collection='+collection+'&key='+key);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := objeto;
       end else begin
         Result := objeto;
       end;

     finally
       lHTTP.Free;
     end;
end;

function TeDB._set_(collection,key:string; payload: TStringStream): boolean;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
begin

     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.post('http://'+Fhost+':'+Fport+'/set?collection='+collection+'&key='+key,payload);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Result := False;
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := True;
       end else begin
         Result := False;
       end;

     finally
       lHTTP.Free;
     end;

end;

end.
