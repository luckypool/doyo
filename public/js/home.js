(function(){
    function Background(){
        this.initialize.apply(this, arguments);
    }
    Background.prototype = {
        initialize: function() {
            this.view = new View();
            this.entryModel = new Model({type:"entry", method:"find"});
            this.currentItemSize = 6;
            this.assignInitialContents();
            this.assignEventHandlers();
            console.log("init.");
        },
        assignEventHandlers: function(){
            var _self = this;
            $('#showMoreButton').click(function(){
                var jButton = $(this);
                jButton.attr("disabled","disabled");
                _self.getEntities({
                    limit  : 6,
                    offset : _self.currentItemSize,
                    order  : 'DESC'
                }).done(function(entities){
                    if(entities.length<1){
                        return;
                    }
                    _self.view.appendEntities(entities);
                    _self.currentItemSize += 6;
                    jButton.removeAttr("disabled");
                });
            });
        },
        assignInitialContents: function(){
            var _self = this;
            this.getEntities({
                limit  : this.currentItemSize,
                offset : 0,
                order  : 'DESC'
            }).done(function(entities){
                _self.view.appendEntities(entities);
            });
        },
        getEntities: function(params){
            var _self = this;
            var dfd = $.Deferred();
            var entities  = [];
            this.entryModel.request(
                params
            ).pipe(function(response){
                var entryArray = response.result;
                for(var i=0;i<entryArray.length;i++){
                    entities.push(
                        new Entity({
                            entryId: entryArray[i].id,
                            nickName: entryArray[i].nickname,
                            body: entryArray[i].body,
                            createdAt: entryArray[i].created_at
                        })
                    );
                }
                dfd.resolve(entities);
            });
            return dfd.promise();
        }
    };

    function View(){
        this.initialize.apply(this, arguments);
    }
    View.prototype = {
        initialize: function(arguments) {
            this.baseHtml = $('#container_template').html();
            this.templateName = "containerTemplate";
            $.template(this.templateName, this.baseHtml);
        },
        appendEntities: function(entities){
            for(var i=0; i<entities.length; i++){
                var newEntity = $.tmpl(this.templateName, entities[i]);
                $('#contents_area_main')
                    .masonry({
                        isAnimated: true,
                        animationOptions: {
                            duration: 400
                        }
                    })
                    .append(newEntity)
                    .masonry('reload');
            }
        }
    };

    function Model(){
        this.initialize.apply(this, arguments);
    }
    Model.prototype = {
        initialize: function(arguments) {
            this.modelType = arguments.type;
            this.method    = arguments.method;
            this.endPoint  = "/api/" + this.modelType + "/rpc.json";
        },
        batchRequest: function(paramArray){
            var _self = this;
            var data = [];
            for(var i=0; i<paramArray.length; i++){
                data.push({
                   jsonrpc : '2.0',
                   method  : this.method,
                   params  : paramArray[i],
                   id      : i+1
                });
            }
            return $.ajax({
                type          : 'POST',
                url           : this.endPoint,
                dataType      : 'json',
                contentType   : 'application/json',
                scriptCharset : 'utf-8',
                data          : JSON.stringify(data)
            }).fail(function(jqXHR, textStatus) {
                console.log( "Request failed: " + textStatus );
            });
        },
        request: function(params){
            var _self = this;
            var data = {
               jsonrpc : '2.0',
               method  : this.method,
               params  : params,
               id      : 1
            };
            return $.ajax({
                type          : 'POST',
                url           : this.endPoint,
                dataType      : 'json',
                contentType   : 'application/json',
                scriptCharset : 'utf-8',
                data          : JSON.stringify(data)
            }).fail(function(jqXHR, textStatus) {
                console.log( "Request failed: " + textStatus );
            });
        }
    };

    function Entity(){
        this.initialize.apply(this, arguments);
    }
    Entity.prototype = {
        initialize: function(arguments) {
            this.entryId = arguments.entryId;
            this.nickName = arguments.nickName;
            this.detail = arguments.body;
            this.createdAt = arguments.createdAt;
        },
        as_hash: function(){
            return {
                entryId: this.entryId,
                nickName: this.nickName,
                detail: this.detail,
                createdAt: this.createdAt
            };
        }
    };

    $(document).ready(function(){
        var bg = new Background();
    });
})();

