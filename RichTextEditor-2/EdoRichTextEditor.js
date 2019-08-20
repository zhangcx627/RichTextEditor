/*!
 *
 * ZSSRichTextEditor v0.5.2
 * http://www.zedsaid.com
 *
 * Copyright 2014 Zed Said Studio LLC
 *
 */

var edo_editor = {};

// If we are using iOS or desktop
edo_editor.isUsingiOS = true;

// If the user is draging
edo_editor.isDragging = false;

// The current selection
edo_editor.currentSelection;

// The current editing image
edo_editor.currentEditingImage;

// The current editing link
edo_editor.currentEditingLink;

// The objects that are enabled
edo_editor.enabledItems = {};

// Height of content window, will be set by viewController
edo_editor.contentHeight = 244;

// Sets to true when extra footer gap shows and requires to hide
edo_editor.updateScrollOffset = false;

/**
 * The initializer function that must be called onLoad
 */
edo_editor.init = function() {
    
    $('#edo_editor_content').on('touchend', function(e) {
                                edo_editor.enabledEditingItems(e);
                                var clicked = $(e.target);
                                if (!clicked.hasClass('zs_active')) {
                                $('img').removeClass('zs_active');
                                }
                                });
    
    $(document).on('selectionchange',function(e){
                   edo_editor.calculateEditorHeightWithCaretPosition();
                   edo_editor.setScrollPosition();
                   edo_editor.enabledEditingItems(e);
                   });
    
    $(window).on('scroll', function(e) {
                 edo_editor.updateOffset();
                 });
    
    // Make sure that when we tap anywhere in the document we focus on the editor
    $(window).on('touchmove', function(e) {
                 edo_editor.isDragging = true;
                 edo_editor.updateScrollOffset = true;
                 edo_editor.setScrollPosition();
                 edo_editor.enabledEditingItems(e);
                 });
    $(window).on('touchstart', function(e) {
                 edo_editor.isDragging = false;
                 });
    $(window).on('touchend', function(e) {
                 if (!edo_editor.isDragging && (e.target.id == "edo_editor_footer"||e.target.nodeName.toLowerCase() == "html")) {
                 edo_editor.focusEditor();
                 }
                 });
    
}//end

edo_editor.updateOffset = function() {
    
    if (!edo_editor.updateScrollOffset)
        return;
    
    var offsetY = window.document.body.scrollTop;
    
    var footer = $('#edo_editor_footer');
    
    var maxOffsetY = footer.offset().top - edo_editor.contentHeight;
    
    if (maxOffsetY < 0)
        maxOffsetY = 0;
    
    if (offsetY > maxOffsetY)
    {
        window.scrollTo(0, maxOffsetY);
    }
    
    edo_editor.setScrollPosition();
}

// This will show up in the XCode console as we are able to push this into an NSLog.
edo_editor.debug = function(msg) {
    window.location = 'debug://'+msg;
}


edo_editor.setScrollPosition = function() {
    var position = window.pageYOffset;
    window.location = 'scroll://'+position;
}


edo_editor.setPlaceholder = function(placeholder) {
    
    var editor = $('#edo_editor_content');
    
    //set placeHolder
	editor.attr("placeholder",placeholder);
	
    //set focus			 
	editor.focusout(function(){
        var element = $(this);        
        if (!element.text().trim().length) {
            element.empty();
        }
    });
	
	
    
}

edo_editor.setFooterHeight = function(footerHeight) {
    var footer = $('#edo_editor_footer');
    footer.height(footerHeight + 'px');
}

edo_editor.getCaretYPosition = function() {
    var sel = window.getSelection();
    // Next line is comented to prevent deselecting selection. It looks like work but if there are any issues will appear then uconmment it as well as code above.
    //sel.collapseToStart();
    var range = sel.getRangeAt(0);
    var span = document.createElement('span');// something happening here preventing selection of elements
    range.collapse(false);
    range.insertNode(span);
    var topPosition = span.offsetTop;
    span.parentNode.removeChild(span);
    return topPosition;
}

edo_editor.calculateEditorHeightWithCaretPosition = function() {
    
    var padding = 50;
    var c = edo_editor.getCaretYPosition();
    
    var editor = $('#edo_editor_content');
    
    var offsetY = window.document.body.scrollTop;
    var height = edo_editor.contentHeight;
    
    var newPos = window.pageYOffset;
    
    if (c < offsetY) {
        newPos = c;
    } else if (c > (offsetY + height - padding)) {
        newPos = c - height + padding - 18;
    }
    
    window.scrollTo(0, newPos);
}

edo_editor.backuprange = function(){
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    edo_editor.currentSelection = {"startContainer": range.startContainer, "startOffset":range.startOffset,"endContainer":range.endContainer, "endOffset":range.endOffset};
}

edo_editor.restorerange = function(){
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(edo_editor.currentSelection.startContainer, edo_editor.currentSelection.startOffset);
    range.setEnd(edo_editor.currentSelection.endContainer, edo_editor.currentSelection.endOffset);
    selection.addRange(range);
}

edo_editor.getSelectedNode = function() {
    var node,selection;
    if (window.getSelection) {
        selection = getSelection();
        node = selection.anchorNode;
    }
    if (!node && document.selection) {
        selection = document.selection
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        node = range.commonAncestorContainer ? range.commonAncestorContainer :
        range.parentElement ? range.parentElement() : range.item(0);
    }
    if (node) {
        return (node.nodeName == "#text" ? node.parentNode : node);
    }
};

edo_editor.setBold = function() {
    document.execCommand('bold', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setItalic = function() {
    document.execCommand('italic', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setSubscript = function() {
    document.execCommand('subscript', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setSuperscript = function() {
    document.execCommand('superscript', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setUnderline = function() {
    document.execCommand('underline', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setBlockquote = function() {
    var range = document.getSelection().getRangeAt(0);
    formatName = range.commonAncestorContainer.parentElement.nodeName === 'BLOCKQUOTE'
    || range.commonAncestorContainer.nodeName === 'BLOCKQUOTE' ? '<P>' : '<BLOCKQUOTE>';
    document.execCommand('formatBlock', false, formatName)
    edo_editor.enabledEditingItems();
}

edo_editor.removeFormating = function() {
    document.execCommand('removeFormat', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setHorizontalRule = function() {
    document.execCommand('insertHorizontalRule', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setHeading = function(heading) {
    var current_selection = $(edo_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_heading = (t == 'h1' || t == 'h2' || t == 'h3' || t == 'h4' || t == 'h5' || t == 'h6');
    if (is_heading && heading == t) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<'+heading+'>');
    }
    
    edo_editor.enabledEditingItems();
}

edo_editor.setParagraph = function() {
    var current_selection = $(edo_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_paragraph = (t == 'p');
    if (is_paragraph) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<p>');
    }
    
    edo_editor.enabledEditingItems();
}

// Need way to remove formatBlock
console.log('WARNING: We need a way to remove formatBlock items');

edo_editor.undo = function() {
    document.execCommand('undo', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.redo = function() {
    document.execCommand('redo', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setUnorderedList = function() {
    document.execCommand('insertUnorderedList', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setJustifyFull = function() {
    document.execCommand('justifyFull', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setIndent = function() {
    document.execCommand('indent', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setOutdent = function() {
    document.execCommand('outdent', false, null);
    edo_editor.enabledEditingItems();
}

edo_editor.setFontFamily = function(fontFamily) {

	edo_editor.restorerange();
	document.execCommand("styleWithCSS", null, true);
	document.execCommand("fontName", false, fontFamily);
	document.execCommand("styleWithCSS", null, false);
	edo_editor.enabledEditingItems();
		
}

edo_editor.setTextColor = function(color) {
		
//    edo_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    edo_editor.enabledEditingItems();
    // document.execCommand("removeFormat", false, "foreColor"); // Removes just foreColor
	
}

edo_editor.setBackgroundColor = function(color) {
    edo_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    edo_editor.enabledEditingItems();
}

// Needs addClass method

edo_editor.insertLink = function(url, title) {
    
    edo_editor.restorerange();
    var sel = document.getSelection();
    console.log(sel);
    if (sel.toString().length != 0) {
        if (sel.rangeCount) {
            
            var el = document.createElement("a");
            el.setAttribute("href", url);
            el.setAttribute("title", title);
            
            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }
    else
    {
        document.execCommand("insertHTML",false,"<a href='"+url+"'>"+title+"</a>");
    }
    
    edo_editor.enabledEditingItems();
}

edo_editor.updateLink = function(url, title) {
    
    edo_editor.restorerange();
    
    if (edo_editor.currentEditingLink) {
        var c = edo_editor.currentEditingLink;
        c.attr('href', url);
        c.attr('title', title);
    }
    edo_editor.enabledEditingItems();
    
}//end

edo_editor.unlink = function() {
    
    if (edo_editor.currentEditingLink) {
        var c = edo_editor.currentEditingLink;
        c.contents().unwrap();
    }
    edo_editor.enabledEditingItems();
}

edo_editor.quickLink = function() {
    
    var sel = document.getSelection();
    var link_url = "";
    var test = new String(sel);
    var mailregexp = new RegExp("^(.+)(\@)(.+)$", "gi");
    if (test.search(mailregexp) == -1) {
        checkhttplink = new RegExp("^http\:\/\/", "gi");
        if (test.search(checkhttplink) == -1) {
            checkanchorlink = new RegExp("^\#", "gi");
            if (test.search(checkanchorlink) == -1) {
                link_url = "http://" + sel;
            } else {
                link_url = sel;
            }
        } else {
            link_url = sel;
        }
    } else {
        checkmaillink = new RegExp("^mailto\:", "gi");
        if (test.search(checkmaillink) == -1) {
            link_url = "mailto:" + sel;
        } else {
            link_url = sel;
        }
    }
    
    var html_code = '<a href="' + link_url + '">' + sel + '</a>';
    edo_editor.insertHTML(html_code);
    
}

edo_editor.prepareInsert = function() {
    edo_editor.backuprange();
}

edo_editor.setHTML = function(html) {
    var editor = $('#edo_editor_content');
    editor.html(html);
}

edo_editor.insertHTML = function(html) {
    document.execCommand('insertHTML', false, html);
    edo_editor.enabledEditingItems();
}

edo_editor.getHTML = function() {
    
    // Images
    var img = $('img');
    if (img.length != 0) {
        $('img').removeClass('zs_active');
        $('img').each(function(index, e) {
                      var image = $(this);
                      var zs_class = image.attr('class');
                      if (typeof(zs_class) != "undefined") {
                      if (zs_class == '') {
                      image.removeAttr('class');
                      }
                      }
                      });
    }
    
    // Blockquote
    var bq = $('blockquote');
    if (bq.length != 0) {
        bq.each(function() {
                var b = $(this);
                if (b.css('border').indexOf('none') != -1) {
                b.css({'border': ''});
                }
                if (b.css('padding').indexOf('0px') != -1) {
                b.css({'padding': ''});
                }
                });
    }
    
    // Get the contents
    var h = document.getElementById("edo_editor_content").innerHTML;
    
    return h;
}

edo_editor.getText = function() {
    return $('#edo_editor_content').text();
}

edo_editor.isCommandEnabled = function(commandName) {
    return document.queryCommandState(commandName);
}

edo_editor.enabledEditingItems = function(e) {
    
    console.log('enabledEditingItems');
    var items = [];
    if (edo_editor.isCommandEnabled('bold')) {
        items.push('bold');
    }
    if (edo_editor.isCommandEnabled('italic')) {
        items.push('italic');
    }
    if (edo_editor.isCommandEnabled('subscript')) {
        items.push('subscript');
    }
    if (edo_editor.isCommandEnabled('superscript')) {
        items.push('superscript');
    }
    if (edo_editor.isCommandEnabled('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (edo_editor.isCommandEnabled('underline')) {
        items.push('underline');
    }
    if (edo_editor.isCommandEnabled('insertOrderedList')) {
        items.push('orderedList');
    }
    if (edo_editor.isCommandEnabled('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (edo_editor.isCommandEnabled('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (edo_editor.isCommandEnabled('justifyFull')) {
        items.push('justifyFull');
    }
    if (edo_editor.isCommandEnabled('justifyLeft')) {
        items.push('justifyLeft');
    }
    if (edo_editor.isCommandEnabled('justifyRight')) {
        items.push('justifyRight');
    }
    if (edo_editor.isCommandEnabled('insertHorizontalRule')) {
        items.push('horizontalRule');
    }
    var formatBlock = document.queryCommandValue('formatBlock');
    if (formatBlock.length > 0) {
        items.push(formatBlock);
    }
    // Images
    $('img').bind('touchstart', function(e) {
                  $('img').removeClass('zs_active');
                  $(this).addClass('zs_active');
                  });
    
    // Use jQuery to figure out those that are not supported
    if (typeof(e) != "undefined") {
        
        // The target element
        var s = edo_editor.getSelectedNode();
        var t = $(s);
        var nodeName = e.target.nodeName.toLowerCase();
        
        // Background Color
        var bgColor = t.css('backgroundColor');
        if (bgColor.length != 0 && bgColor != 'rgba(0, 0, 0, 0)' && bgColor != 'rgb(0, 0, 0)' && bgColor != 'transparent') {
            items.push('backgroundColor');
        }
        // Text Color
        var textColor = t.css('color');
        if (textColor.length != 0 && textColor != 'rgba(0, 0, 0, 0)' && textColor != 'rgb(0, 0, 0)' && textColor != 'transparent') {
            items.push('textColor');
        }
		
		//Fonts
		var font = t.css('font-family');
		if (font.length != 0 && font != 'Arial, Helvetica, sans-serif') {
			items.push('fonts');	
		}
		
        // Link
        if (nodeName == 'a') {
            edo_editor.currentEditingLink = t;
            var title = t.attr('title');
            items.push('link:'+t.attr('href'));
            if (t.attr('title') !== undefined) {
                items.push('link-title:'+t.attr('title'));
            }
            
        } else {
            edo_editor.currentEditingLink = null;
        }
        // Blockquote
        if (nodeName == 'blockquote') {
            items.push('indent');
        }
        // Image
        if (nodeName == 'img') {
            edo_editor.currentEditingImage = t;
            items.push('image:'+t.attr('src'));
            if (t.attr('alt') !== undefined) {
                items.push('image-alt:'+t.attr('alt'));
            }
            
        } else {
            edo_editor.currentEditingImage = null;
        }
        
    }
    
    if (items.length > 0) {
        if (edo_editor.isUsingiOS) {
            //window.location = "zss-callback/"+items.join(',');
            window.location = "callback://0/"+items.join(',');
        } else {
            console.log("callback://"+items.join(','));
        }
    } else {
        if (edo_editor.isUsingiOS) {
            window.location = "zss-callback/";
        } else {
            console.log("callback://");
        }
    }
    
}

edo_editor.focusEditor = function() {
    
    // the following was taken from http://stackoverflow.com/questions/1125292/how-to-move-cursor-to-end-of-contenteditable-entity/3866442#3866442
    // and ensures we move the cursor to the end of the editor
    var editor = $('#edo_editor_content');
    var range = document.createRange();
    range.selectNodeContents(editor.get(0));
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    editor.focus();
}

edo_editor.blurEditor = function() {
    $('#edo_editor_content').blur();
}

edo_editor.setCustomCSS = function(customCSS) {
    
    document.getElementsByTagName('style')[0].innerHTML=customCSS;
    
    //set focus
    /*editor.focusout(function(){
                    var element = $(this);
                    if (!element.text().trim().length) {
                    element.empty();
                    }
                    });*/
    
    
    
}

//end
