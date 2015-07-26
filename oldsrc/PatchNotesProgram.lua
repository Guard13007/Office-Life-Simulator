local class = require "lib.middleclass"
local Program = require "Program"
local lf = require "lib.LoveFrames"

local PatchNotesProgram = class('PatchNotesProgram', Program)

function PatchNotesProgram:initialize(computer)
    self._programName = "Patch Notes"
    --self.icon = "images/PatchNotesProgramIconDefault.png"

    self._Computer = computer
end

function PatchNotesProgram:SetComputer(computer)
    self._Computer = computer
end

function PatchNotesProgram:GetComputer()
    return self._Computer
end

local temporaryIntroText = [[
Hello! Welcome to Office Life (Simulator)!

Hope you don't mind me breaking the 4th wall for a second. Just wanted to say this is a very early prototype, and might be buggy. Please do report any problems you have and ask any questions you have.

That said, if you ask a question that I'm answering right now, I will ignore you. :D

- The objective of the game is to respond to emails correctly. You do this by scanning them for the word "lorem" or the word "ipsum" and click whichever you find. Note that there is a small chance of both words being in the text, that's something that will be fixed later, for now, it means there's an email you can't get wrong!
- For emails that have "Reply" and "Delete" instead, there are future plans for them, but for now, it does not matter what you do.
- Want to see your score? Look at the icon in the bottom right near the game-clock, click it.
- Right now you have one save-game. In the future, I will have a system for multiple saves, and you will choose which one you want to load by the username you type in when wanting to log in.
- Like I said before, contact me with any questions, suggestions, complaints, or money you'd like to give me...although I don't know why you'd want to..]]

function PatchNotesProgram:Open()
    if not self:isOpen() then
        self._mainLF = lf.Create('frame')
        self._mainLF:SetName("Patch Notes")
        self._mainLF:SetSize(400, 500)
        self._mainLF:Center()

        self._list = lf.Create('list', self._mainLF)
        self._list:SetPos(5, 30)
        local w, h = self._mainLF:GetSize()
        self._list:SetSize(w - 10, h - 35)
        self._list:SetPadding(5)

        self._text = lf.Create('text', self._list)
        self._text:SetText(temporaryIntroText)

        self._open = true
    end
end

function PatchNotesProgram:Show()
    if self:isOpen() then
        self._mainLF:SetVisible(true)
    else
        print("PatchNotesProgram tried to Show while not open.")
    end
end

function PatchNotesProgram:Hide()
    if self:isOpen() then
        self._mainLF:SetVisible(false)
    else
        print("PatchNotesProgram tried to Hide while not open.")
    end
end

function PatchNotesProgram:Close()
    if self:isOpen() then
        self._mainLF:Remove()

        self._open = false
    else
        print("PatchNotesProgram tried to close when already closed.")
    end
end

return PatchNotesProgram
