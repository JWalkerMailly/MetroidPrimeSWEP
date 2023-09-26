
WGL = WGL || {};
WGL.Scaling = {
	Width = 1024,
	Height = 768
}

function WGL.PushScaling(width, height)
	WGL.Scaling.Width  = width;
	WGL.Scaling.Height = height;
end

function WGL.PopScaling()
	WGL.Scaling.Width  = 1024;
	WGL.Scaling.Height = 768;
end

function WGL.X(value)
	return value / WGL.Scaling.Width * ScrW();
end

function WGL.Y(value)
	return value / WGL.Scaling.Height * ScrH();
end

function WGL.Circle(x, y, w, h, segments, r, g, b, a, output)

	local poly   = output || {};
	local _x     = w / 2;
	local _y     = h / 2;
	local radius = h / 2;

	if (#poly <= 0) then
		table.insert(poly, { x = x + _x, y = y + _y });
		for i = 0, segments do
			local _a = math.rad((i / segments) * -360);
			table.insert(poly, { x = x + _x + math.sin(_a) * radius, y = y + _y + math.cos(_a) * radius });
		end
		table.insert(poly, { x = x + _x, y = y + _y + radius });
	end

	surface.SetDrawColor(r, g, b, a);
	draw.NoTexture();
	surface.DrawPoly(poly);
	return poly;
end

function WGL.Rect(x, y, w, h, r, g, b, a)
	surface.SetDrawColor(r, g, b, a);
	surface.DrawRect(x, y, w, h);
end

function WGL.RectRotOrigin(x, y, w, h, angle, r, g, b, a)

	local ang = math.rad(angle)
	local cos = math.cos(ang);
	local sin = math.sin(ang);

	local quad = {
		{ x = x, y = y },
		{ x = cos * w - sin * 0 + x, y = sin * w + cos * 0 + y },
		{ x = cos * w - sin * h + x, y = sin * w + cos * h + y },
		{ x = cos * 0 - sin * h + x, y = sin * 0 + cos * h + y }
	};

	surface.SetDrawColor(r, g, b, a);
	draw.NoTexture();
	surface.DrawPoly(quad);
end

function WGL.Texture(material, x, y, w, h, r, g, b, a)
	surface.SetDrawColor(r, g, b, a);
	surface.SetMaterial(material);
	surface.DrawTexturedRect(x, y, w, h);
end

function WGL.TextureUV(material, x, y, w, h, u, v, u2, v2, center, r, g, b, a)

	if (center) then
		x = x - w / 2;
		y = y - h / 2;
	end

	surface.SetDrawColor(r, g, b, a);
	surface.SetMaterial(material);
	surface.DrawTexturedRectUV(x, y, w, h, u, v, u2, v2);

	return x, y;
end

function WGL.TextureRot(material, x, y, w, h, degrees, r, g, b, a)
	surface.SetDrawColor(r, g, b, a);
	surface.SetMaterial(material);
	surface.DrawTexturedRectRotated(x, y, w, h, degrees);
end

function WGL.AnimatedText(text, font, x, y, color, align, start, rate)

	local length   = string.len(text);
	local progress = math.Clamp(math.floor((CurTime() - start) / rate), 0, length);

	-- Draw 1 character at a time according to the supplied rate.
	draw.SimpleText(string.sub(text, 1, progress), font, x, y, color, align);
	return progress == length;
end

function WGL.TruncatedText(text, font, maxWidth)

	surface.SetFont(font);
	local ellipsis,  _ = surface.GetTextSize("...");
	local textWidth, _ = surface.GetTextSize(text);

	if (textWidth <= maxWidth) then return text; end

	for i = 1, string.len(text) do

		local sub = string.sub(text, 1, i);
		local subWidth, _ = surface.GetTextSize(sub);

		if (subWidth > maxWidth - ellipsis) then
			text = string.TrimRight(string.sub(text, 1, math.max(i - 1, 1))) .. "...";
			break;
		end
	end

	return text;
end

function WGL.FitText(text, font, maxWidth, maxHeight, lineHeight, top, right, bottom, left)

	-- Make sure entry is valid before parsing.
	if (!isstring(text)) then return nil; end

	-- Make sure text height fits inside area or that whole text does not already fit whole width.
	surface.SetFont(font);
	local areaWidth = maxWidth - (left || 0) - (right || 0);
	local areaHeight = maxHeight - (top || 0) - (bottom || 0);
	local textWidth, textHeight = surface.GetTextSize(text);
	if (textHeight > areaHeight) then return { { "" } }; end
	if (textWidth <= areaWidth) then return { { text } }; end

	-- Setup line and paragraph processing.
	local line            = nil;
	local lineIndex       = 1;
	local paragraphs      = {};
	local paragraphIndex  = 1;
	local paragraphHeight = lineHeight || textHeight;

	-- Begin text processing.
	for word in string.gmatch(text, "[%S]+") do

		-- Word does not fit in given area, truncate.
		local overflow = false;
		local wordWidth, _ = surface.GetTextSize(word .. " ");
		if (wordWidth > areaWidth) then
			word = WGL.TruncatedText(word, font, areaWidth);
		end

		-- First word being processed, add it now.
		if (line == nil) then
			line = word;
		else

			-- New word overflows the current line, raise flag.
			local newWord = line .. " " .. word;
			local newWidth, _ = surface.GetTextSize(newWord);
			if (newWidth > areaWidth) then
				overflow = true;
				newWord = word;
			end

			-- Update line entry with new word.
			if (overflow) then

				-- Paragraph is taller than max height, prepare next paragraph.
				fontHeight = lineHeight || textHeight;
				paragraphHeight = paragraphHeight + fontHeight;
				if (paragraphHeight > areaHeight - (bottom || 0)) then
					paragraphHeight = fontHeight;
					paragraphIndex = paragraphIndex + 1;
					lineIndex = 0;
				end

				lineIndex = lineIndex + 1;
			end

			line = newWord;
		end

		-- Initialize paragraph container.
		if (paragraphs[paragraphIndex] == nil) then
			paragraphs[paragraphIndex] = {};
		end

		-- Initialize paragraph line container.
		if (paragraphs[paragraphIndex][lineIndex] == nil) then
			paragraphs[paragraphIndex][lineIndex] = "";
		end

		paragraphs[paragraphIndex][lineIndex] = line;
	end

	return paragraphs;
end

function WGL.Paragraph(paragraph, font, x, y, lineHeight, color)

	-- Render paragraph lines.
	local lineIndex = 0;
	for k, v in pairs(paragraph) do
		draw.SimpleText(v, font, x, y + lineIndex * lineHeight, color);
		lineIndex = lineIndex + 1;
	end
end

function WGL.GetRenderTexture(cache, name, w, h, options, dynamic)

	-- Cache setup.
	cache.RenderTargets  = cache.RenderTargets  || {};
	cache.RenderTextures = cache.RenderTextures || {};

	-- Prevent recreating render objects if it is already done, or if dynamic resolution did not change.
	local renderTexture = cache.RenderTextures[name];
	if (cache.RenderTargets[name] != nil && (!dynamic || (dynamic && w == renderTexture:Width() && h == renderTexture:Height()))) then
		return cache.RenderTargets[name], cache.RenderTextures[name];
	end

	-- Create render target using provided options.
	local renderTargetID       = w .. "x" .. h;
	cache.RenderTargets[name]  = GetRenderTargetEx(name .. renderTargetID, w, h, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(2, 256), CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_BGRA8888);
	options["$basetexture"]    = cache.RenderTargets[name]:GetName();
	cache.RenderTextures[name] = CreateMaterial(name .. renderTargetID, "UnlitGeneric", options);
	return cache.RenderTargets[name], cache.RenderTextures[name];
end