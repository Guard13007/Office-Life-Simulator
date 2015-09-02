local class = require "lib.middleclass"
local Program = require "programs.Program"
local lf = require "lib.LoveFrames"

local PatchNotesProgram = class("PatchNotesProgram", Program)

function PatchNotesProgram:initialize()
    Program.initialize(self)
    self._programName = "Patch Notes"

    self._list = nil
    self._text = nil
end

--NOTE/TODO make sure this displays once and only once on first run, regardless of user saves?
-- (separate save file for info about whether or not to show this)

local temporaryIntroText = [[
Hello! Welcome to Office Life (Simulator)!

Hope you don't mind me breaking the 4th wall for a second. Just wanted to say this is a very early prototype, and might be buggy. Please do report any problems you have and ask any questions you have.

That said, if you ask a question that I'm answering right now, I will ignore you. :D

- The objective of the game is to respond to emails correctly. You do this by scanning them for the word "lorem" or the word "ipsum" and click whichever you find. Note that there is a small chance of both words being in the text, that's something that will be fixed later, for now, it means there's an email you can't get wrong!
- For emails that have "Reply" and "Delete" instead, there are future plans for them, but for now, it does not matter what you do.
- Want to see your score? Look at the icon in the bottom right near the game-clock, click it.
- Right now you have one save-game. In the future, I will have a system for multiple saves, and you will choose which one you want to load by the username you type in when wanting to log in.
- Like I said before, contact me with any questions, suggestions, complaints, or money you'd like to give me...although I don't know why you'd want to..]]

function PatchNotesProgram:open()
    if not self._open then
        self.mainLF = lf.Create("frame")
        self.mainLF:SetName("Patch Notes")
        self.mainLF:SetSize(400, 500)
        self.mainLF:Center()

        self._list = lf.Create("list", self.mainLF)
        self._list:SetPos(5, 30)
        local w, h = self.mainLF:GetSize()
        self._list:SetSize(w - 10, h - 35)
        self._list:SetPadding(5)

        self._text = lf.Create("text", self._list)
        self._text:SetText(temporaryIntroText)

        self._open = true
    end
end

function PatchNotesProgram:show()
    if self._open then
        self.mainLF:SetVisible(true)
    end
end

function PatchNotesProgram:hide()
    if self._open then
        self.mainLF:SetVisible(false)
    end
end

function PatchNotesProgram:close()
    if self._open then
        self._text:Remove()
        self._list:Remove()
        self.mainLF:Remove()

        self._open = false
    end
end

return PatchNotesProgram
