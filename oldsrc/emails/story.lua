local emails = {
    welcomeToJob = {
        subject = "Welcome to <insert company name>!",
        from = "<some generated name>, <some official title>",
        text = [[
Hello, <insert name here>! You have recently been hired at <company name here>.

At <company name here>, we are proud to continue a long-held tradition of <something something something>. We strive for excellence in our industry, and an important part of that is having plenty of office drones to fill our big, expensive buildings with.

We at <company name here> welcome you, <insert name here>. Please remember to always stay on task at your computer and avoid slacking off and taking breaks! Emails usually come in pretty quickly, and it is vital you respond to each one appropriately.

Sincerely, <some generated name>, <some official title>.]],
        --time = 0,
        --type = "Story"
    },
    firstLateEmail = {
        subject = "Please remember to respond to emails within a reasonable time.",
        from = "<some generated name>, <some official title>",
        text = [[
Dear <insert name here>, it has come to our attention that you have failed to respond to an email within a reasonable amount of time.

At <company name here>, we pride ourselves on efficient and productive work at all times. Please remember, all emails must be responded to with 1 (one) hour of their send date, and must be correctly responded to, or you will lose points on your productivity score. If your productivity score goes too low, you will be fired, and replaced with a more competent employee.

Please remember to respond to emails on time.]],
        --time = 0,
        --type = "Story"
    },
    --firstIncorrectEmail
    incorrectEmail = {
        subject = "Please remember to respond to emails correctly.",
        from = "<some generated name>, <some official title>",
        text = [[
Dear <insert name here>, it has come to our attention that you have failed to adequately respond to an email in a satisfactory manner.

At <company name here>, we pride ourselves on efficient and productive work at all times. Please remember, all emails must be responded to with 1 (one) hour of their send date, and must be correctly responded to, or you will lose points on your productivity score. If your productivity score goes too low, you will be fired, and replaced with a more competent employee.

Please remember to search the email text for "lorem" or "ipsum" and reply appropriately. Lorem emails should be marked Lorem. Ipsum emails should be marked Ipsum.]],
    }
}

for k,v in pairs(emails) do
    emails[k].time = 0
    emails[k].type = "Story"
end

return emails
