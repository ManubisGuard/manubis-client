# ManubisGuard Android + Store: TODO & Work Log

> این فایل مرجع اصلی برنامه‌ریزی و گزارش پیشرفت پروژه است. هر کار باید پس از بررسی واقعی، با وضعیت و نتیجه ثبت شود. چیزی را Done نزن مگر اینکه اجرا و تأیید شده باشد.

## مشخصات پروژه

- **محصول:** ManubisGuard Android
- **کلاینت:** سورس Amnezia Client در `./android`
- **Repository:** `https://github.com/ManubisGuard/manubis-client`
- **Branch بررسی‌شده:** `dev`
- **پنل اصلی:** `https://vip.qoqnusradio.top/dashboard/`
- **محل پروژه روی سرور:** `/opt/manubisguard-android`
- **Backend/Store:** نمونه اولیه FastAPI، مدل‌های پلن/سفارش، migration، کاتالوگ عمومی و API مدیریت پلن/قالب ساخته شده؛ سفارش/پرداخت واقعی و provisioning امن هنوز تکمیل نشده‌اند.
- **Admin Dashboard:** داشبورد اولیه در `store-backend/app/static/admin.html` موجود است؛ برای production نیاز به سخت‌سازی امنیتی و محدودسازی دسترسی دارد.
- **محدودیت مهم:** هیچ API key، token، password یا secret نباید در این فایل، Git، لاگ یا APK ثبت شود. کلیدی که در گفتگو ارسال شده در این فایل ذخیره نشده است؛ به‌دلیل افشا، ابطال و جایگزینی آن توصیه می‌شود.

## وضعیت‌ها

- `[ ]` انجام‌نشده
- `[-]` در حال انجام
- `[x]` تکمیل و بررسی‌شده
- `[!]` مسدود / نیازمند بررسی یا اطلاعات بیشتر

---

## فاز 0: ثبت محدوده و بررسی اولیه

- [x] مسیر کاری `/opt/manubisguard-android` شناسایی شد.
- [x] سورس کلاینت در `./android` موجود است.
- [x] وضعیت Git بررسی شد: branch `dev` و در زمان بررسی working tree پاک بود (`dev...origin/dev`).
- [x] `PROJECT_BRIEF.md` خوانده شد و به‌عنوان خلاصه جهت محصول موجود است.
- [x] آدرس پنل اصلی از طرف کاربر تأیید شد: `https://vip.qoqnusradio.top/dashboard/`.
- [x] کاربر اعلام کرد API key ارسال‌شده را از خود پنل ساخته است؛ مقدار کلید در مستندات پروژه ذخیره نمی‌شود.
- [ ] در صورت امکان، API key افشاشده باطل و یک کلید جدید با حداقل دسترسی لازم ساخته شود.

## فاز 1: ممیزی کلاینت و قابلیت‌های موجود

- [x] وجود `StorePurchaseController` بررسی شد.
- [x] وجود `ServicesCatalogController` بررسی شد.
- [x] وجود `SubscriptionController` بررسی شد.
- [x] بررسی اولیه نشان داد کلاینت منطق کاتالوگ سرویس‌ها و خرید درون‌برنامه‌ای Google Play / Apple را دارد؛ این به‌تنهایی به معنی سازگاری با فروشگاه و پرداخت مستقیم ManubisGuard نیست.
- [x] مسیرهای اصلی UI/QML مربوط به کاتالوگ و خرید بررسی و در `docs/STORE_API_AUDIT.md` ثبت شدند؛ بررسی صفحه‌های حساب و جزئیات UI هنوز ادامه دارد.
- [-] تنظیمات Gateway endpoint و payloadهای پایه بررسی شدند؛ احراز هویت کامل Gateway و پنل هنوز باید از کد و قرارداد API استخراج شود.
- [x] ارزیابی اولیه ثبت شد: کاتالوگ/انتخاب پلن/ورود کانفیگ و اطلاعات اشتراک قابل استفاده مجددند؛ کیف پول، سفارش‌ها و پرداخت مستقیم هنوز اثبات نشده و احتمالاً نیاز به Backend دارند.
- [ ] سازگاری واقعی هسته با AmneziaWG 2.x از روی کد و وابستگی‌ها بررسی شود؛ تا آن زمان هسته VPN تغییر نکند.
- [ ] روش build اندروید، نسخه Qt/SDK/NDK و تست‌های قابل اجرا ثبت شوند.

## فاز 2: ممیزی API پنل اصلی

- [x] آدرس‌های عمومی متداول مستندات (`/openapi.json`، `/docs` و `/redoc`) بررسی شدند؛ هر سه در بررسی اولیه پاسخ `404` دادند.
- [x] احراز هویت API و routeهای اولیه از سورس پنل محلی استخراج شد: `X-Api-Key` یا `Authorization: ApiKey <key>`؛ تست زنده با کلید جدید و محدودشده هنوز انجام نشده است.
- [ ] فقط درخواست‌های خواندنی و کم‌خطر برای شناسایی API اجرا شوند.
- [-] مسیرهای اولیه ساخت/خواندن/ویرایش کاربر، ساخت از template و خواندن template شناسایی شدند؛ mapping دقیق پلن، مصرف، انقضا و لینک اشتراک هنوز باید کامل شود.
- [x] در سورس کلاینت فعلی شواهدی از API کیف پول/سفارش/پرداخت مستقیم/کوپن دیده نشد؛ باید سورس پنل و API آن جداگانه ممیزی شوند.
- [-] routeها و مدل‌های اصلی در `docs/PANEL_API_CAPABILITIES.md` ثبت شدند؛ نمونه responseهای نهایی و mapping گروه/پلن هنوز باقی است.
- [ ] محدودیت‌های API و تفاوت‌های احتمالی با PasarGuard upstream ثبت شوند.

## فاز 3: طراحی معماری Store Backend

- [-] Backend با FastAPI scaffold شده؛ انتخاب دیتابیس هنوز باز است و قبل از پیاده‌سازی سفارش/کیف پول نهایی می‌شود.
- [-] پیش‌نویس قرارداد مستقل در `docs/STORE_API_CONTRACT.md` ثبت شد؛ هنوز endpointهای کسب‌وکاری پیاده‌سازی نشده‌اند.
- [-] اسکلت `store-backend/app/panel/client.py` با اتصال فقط خواندنی و credential سمت سرور ایجاد شد؛ mapping کامل adapter باقی است.
- [ ] تنظیمات حساس پنل فقط سمت سرور نگهداری شوند.
- [ ] مدل‌های کاربر، پلن، سفارش، پرداخت، کیف پول و ledger تراکنش‌ها طراحی شوند.
- [ ] احراز هویت، سطح دسترسی، rate limit، اعتبارسنجی ورودی و ثبت رویدادهای audit طراحی شوند.
- [ ] سیاست idempotency و جلوگیری از ثبت دوباره پرداخت/فعال‌سازی تعریف شود.
- [ ] رفتار خطا و timeout هنگام قطع دسترسی پنل طراحی شود.

## فاز 4: پیاده‌سازی Store Backend

- [ ] اسکلت پروژه، تنظیمات محیطی و اجرای توسعه‌ای ایجاد شود.
- [ ] اتصال امن به پنل و health/status check پیاده‌سازی شود.
- [ ] API دریافت پلن‌ها و اطلاعات اشتراک پیاده‌سازی شود.
- [ ] حساب کاربری و guest/import flow مطابق نیاز محصول پیاده‌سازی شود.
- [ ] سفارش، تمدید و وضعیت پرداخت پیاده‌سازی شوند.
- [ ] کیف پول و تاریخچه تراکنش فقط با ثبت ledger قابل حسابرسی پیاده‌سازی شوند.
- [ ] تأیید پرداخت و فعال‌سازی اشتراک کاملاً server-side انجام شود.
- [ ] تست‌های unit/integration و تست خطا اضافه شوند.
- [ ] secrets از logها و responseها حذف/ماسک شوند.

## فاز 5: ساخت Admin Dashboard

- [ ] ورود امن مدیر و نقش‌ها/سطوح دسترسی پیاده‌سازی شوند.
- [ ] تنظیم Base URL پنل و نوع Adapter از داشبورد قابل مدیریت باشد.
- [ ] تنظیم credential به‌شکل ماسک‌شده و امن فراهم شود؛ secret کامل پس از ذخیره نمایش داده نشود.
- [ ] دکمه تست اتصال و نمایش وضعیت آخرین بررسی اضافه شود.
- [ ] مدیریت پلن‌ها و mapping پلن فروشگاه به محصول/پلن پنل پیاده‌سازی شود.
- [ ] مدیریت سفارش‌ها، تراکنش‌ها و وضعیت فعال‌سازی اضافه شود.
- [ ] تغییر تنظیمات مهم audit log داشته باشد.
- [ ] تنظیمات حساس با validation و دسترسی محدود محافظت شوند.

## فاز 6: ادغام فروشگاه در اپ اندروید

- [ ] طراحی UI مطابق هویت ManubisGuard: مشکی/سرمه‌ای با accent آبی/فیروزه‌ای.
- [ ] داشبورد وضعیت اتصال، سرور، زمان اتصال، حجم و انقضا.
- [ ] صفحه پلن‌ها و جزئیات اشتراک.
- [ ] جریان خرید و تمدید متصل به Backend.
- [ ] کیف پول، تاریخچه سفارش و تراکنش در صورت پشتیبانی Backend.
- [ ] ورود با حساب و حالت مهمان/واردکردن کانفیگ شخصی.
- [ ] فارسی و انگلیسی، RTL صحیح برای فارسی.
- [ ] خطاهای شبکه، loading/empty states و پیام‌های کاربرپسند.
- [ ] کلید مدیریتی پنل در APK یا سورس کلاینت قرار نگیرد.

## فاز 7: امنیت، تست و انتشار آزمایشی

- [ ] تست قرارداد API و adapter با پنل واقعی در محیط کنترل‌شده.
- [ ] تست دسترسی غیرمجاز و جداسازی حساب کاربران.
- [ ] تست پرداخت ناموفق، پرداخت تکراری، درخواست تکراری و تأخیر/قطع پنل.
- [ ] تست عدم فعال‌سازی اشتراک صرفاً بر اساس پاسخ کلاینت.
- [ ] تست import/guest flow و عدم افشای کانفیگ‌ها در log.
- [ ] build واقعی Android و ثبت نتیجه دقیق build.
- [ ] تست روی دستگاه/شبیه‌ساز و ثبت باگ‌ها.
- [ ] تهیه نسخه آزمایشی و چک‌لیست انتشار.
- [ ] مستندسازی backup، deployment، rollback و rotation کلیدها.

## فاز 8: استقرار و نگهداری

- [ ] استقرار Backend و Admin Dashboard در سرویس جدا از پنل VPN.
- [ ] HTTPS، firewall، backup دیتابیس و مانیتورینگ تنظیم شوند.
- [ ] migration دیتابیس و روش rollback بررسی شود.
- [ ] اتصال واقعی با پنل و خرید آزمایشی end-to-end تأیید شود.
- [ ] راهنمای مدیر و راهنمای انتشار اپ نوشته شوند.
- [ ] برنامه توسعه آتی Windows پس از تثبیت نسخه Android بررسی شود.

---

## گزارش کار (Work Log)

### 2026-10-15: ثبت وضعیت اولیه

- سورس موجود در `/opt/manubisguard-android/android` بررسی شد.
- Git status در branch `dev` پاک بود و تغییر محلی ثبت‌نشده‌ای در زمان بررسی دیده نشد.
- `PROJECT_BRIEF.md` مطالعه شد.
- وجود کنترلرهای `StorePurchaseController`، `ServicesCatalogController` و `SubscriptionController` تأیید شد.
- کد فعلی خرید درون‌برنامه‌ای Google Play/Apple دارد؛ هنوز ثابت نشده که جریان خرید آن با فروشگاه مستقیم ManubisGuard یا کیف پول/پرداخت داخلی سازگار باشد.
- مسیرهای رایج مستندات OpenAPI در دامنه پنل در بررسی اولیه `404` دادند؛ API authenticated هنوز بررسی کامل نشده است.
- هیچ تغییری در پنل اصلی، کانتینرها یا سرویس‌های فعال اعمال نشد.
- این فایل برای فازبندی و ثبت تمام کارهای بعدی ایجاد شد.


### 2026-10-15: شروع ممیزی فنی کلاینت و Store

- Desktop Commander به دستگاه `CLY914129` متصل شد و مسیر `/opt/manubisguard-android/android` بررسی شد.
- branch جاری `dev` و وضعیت اولیه Git پاک بود؛ commit بررسی‌شده `30ff3451` است.
- کد `StorePurchaseController`، `ServicesCatalogController`، `SubscriptionController` و صفحات انتخاب سرویس/پلن بررسی شدند.
- قرارداد Gateway موجود در کلاینت شامل `v1/services`, `v1/config`, `v1/trial`, `v1/account_info`, `v1/renewal_link` و چند مسیر مربوط به خرید/بازیابی Google Play و App Store است. این‌ها endpointهای Gateway کلاینت هستند و هنوز ثابت نشده که endpointهای پنل ManubisGuard باشند.
- آدرس پیش‌فرض Gateway در سورس `http://gw.amnezia.org:80/` است؛ بنابراین صرفاً عوض‌کردن URL به آدرس داشبورد PasarGuard کافی نیست و می‌تواند قرارداد ناسازگار ایجاد کند.
- مسیرهای عمومی `/openapi.json`, `/docs`, `/redoc` روی دامنه پنل قبلاً بدون ارسال کلید، HTTP 404 داده‌اند.
- گزارش ممیزی در `docs/STORE_API_AUDIT.md` ساخته شد. هیچ secret یا API key در آن ثبت نشده است.
- هیچ تغییری در پنل، کانتینرها یا سرویس‌های فعال اعمال نشد.
- **قدم بعدی:** بررسی سورس پنل ManubisGuard/PasarGuard برای استخراج routeها، auth و قابلیت‌های user/template/usage/expiry؛ سپس طراحی Store Backend بر مبنای قرارداد واقعی.


### 2026-10-15: بررسی سورس API پنل

- سورس پنل محلی در `/opt/manubisguard-panel` پیدا و وضعیت Git بررسی شد: branch `feature/amnezia-wg`، working tree پاک.
- روش API key در کد تأیید شد: header برابر `X-Api-Key` یا `Authorization: ApiKey <key>`؛ کلید باید فعال باشد و prefix آن `pg_key_` است.
- مکانیزم API key از permissionهای ادمین ارث می‌برد یا می‌تواند permission اختصاصی داشته باشد. برای Store Backend باید کلید اختصاصی با حداقل دسترسی ساخته شود؛ کلید ارسال‌شده در گفتگو نباید استفاده شود.
- routeهای اولیه `POST /api/user`، `GET /api/user/{username}`، `PUT /api/user/{username}`، `POST /api/user/from_template` و `GET /api/user_template/s` از سورس شناسایی شدند.
- API پنل یک control-plane برای مدیریت کاربر/قالب/اشتراک است؛ در مسیرها و مدل‌های بررسی‌شده، سیستم فروشگاه شامل سفارش، کیف پول، پرداخت و ledger تراکنش مشاهده نشد.
- مستند جدید `docs/PANEL_API_CAPABILITIES.md` ایجاد شد.
- هیچ درخواست authenticated با کلید ارسال‌شده اجرا نشد و هیچ تغییری در پنل production اعمال نشد.
- **قدم بعدی:** تکمیل mapping دقیق گروه‌ها، قالب‌ها، ساخت کاربر و لینک اشتراک؛ سپس تعریف قرارداد Store Backend و شروع اسکلت پیاده‌سازی.


### 2026-10-15: آغاز اسکلت Store Backend

- پیش‌نویس قرارداد API فروشگاه در `docs/STORE_API_CONTRACT.md` ایجاد شد؛ مسیرهای پیش‌نهادی به‌صراحت از APIهای موجود پنل تفکیک شده‌اند.
- اسکلت FastAPI در `store-backend/` ایجاد شد: تنظیمات امن، health/liveness/readiness و client اولیه پنل با `X-Api-Key`.
- تنظیمات secret فقط از environment / فایل `.env` محلی خوانده می‌شوند؛ `.env` واقعی ساخته نشده و هیچ کلیدی در فایل‌ها قرار نگرفته است.
- Base URL پنل به HTTPS محدود شده و redirect خودکار در client غیرفعال است.
- تست‌های اولیه برای اعتبارسنجی URL و رفتار read-only client نوشته شدند؛ اجرای تست‌ها منوط به نصب وابستگی‌های پروژه است.
- بررسی syntax همه فایل‌های Python با `ast.parse` موفق بود؛ این تست جایگزین اجرای کامل pytest یا اجرای سرور نیست.
- اجرای pytest مسدود شد: این سرور Python 3.12 دارد اما `python3-venv` و `pip` نصب نیستند؛ تلاش برای ساخت virtualenv بدون تغییر بسته‌های سیستمی متوقف شد.
- **قدم بعدی:** فراهم‌کردن محیط تست ایزوله بدون تغییر سرویس‌های موجود، اجرای pytest، سپس تکمیل schemaهای پنل و طراحی دیتابیس قبل از پیاده‌سازی سفارش/پرداخت.


### 2026-10-15: تکمیل لایه اولیه پنل و مدل‌های فروشگاه

- `PanelClient` از اتصال آزمایشی به یک adapter اولیه گسترش یافت: فهرست قالب‌ها، خواندن کاربر و ساخت کاربر از template. مسیرهای استفاده‌شده با سورس پنل تطبیق داده شدند.
- endpoint عمومی `GET /api/v1/store/plans` اضافه شد؛ فقط پلن‌های فعال را برمی‌گرداند و `panel_template_id` داخلی را در پاسخ عمومی افشا نمی‌کند.
- مدل‌های اولیه SQLAlchemy برای `StorePlan` و `StoreOrder` اضافه شدند. قیدهای یکتایی برای idempotency سفارش و شناسه تراکنش درگاه در نظر گرفته شده‌اند؛ این‌ها هنوز جایگزین تست concurrency یا migration نیستند.
- تنظیم `DATABASE_URL` به config و `.env.example` اضافه شد؛ هیچ اتصال دیتابیسی ساخته یا مهاجرتی روی دیتابیس موجود اجرا نشد.
- تست adapter به مسیر واقعی `GET /api/user_template/s` اصلاح شد.
- بررسی AST تمام فایل‌های Python و parse کردن `pyproject.toml` موفق بود. اجرای pytest هنوز ممکن نیست، چون `pip` و `python3-venv` در محیط میزبان موجود نیستند؛ هیچ بسته سیستمی نصب نشد.
- **قدم بعدی:** تهیه migration قابل تکرار، فراهم‌کردن محیط تست ایزوله، سپس تست رفتار adapter با `httpx.MockTransport` و تست endpoint کاتالوگ با دیتابیس آزمایشی. پیش از پرداخت باید احراز هویت مشتری، انتخاب درگاه و سیاست واحد پولی مشخص شود.

## قالب گزارش‌های بعدی

برای هر نشست کاری یک بخش جدید به ابتدای Work Log اضافه شود و شامل موارد زیر باشد:

- **تاریخ و فاز:**
- **کارهای انجام‌شده:**
- **فایل‌ها/مسیرهای تغییرکرده:**
- **تست‌ها و نتیجه واقعی:**
- **موارد مسدود یا ریسک‌ها:**
- **قدم بعدی:**


### 2026-10-15: migration اولیه دیتابیس

- وابستگی Alembic اضافه و فایل‌های `migrations/env.py` و `migrations/versions/0001_initial_store_tables.py` ایجاد شدند.
- migration شامل جدول‌های `store_plans` و `store_orders`، indexها، قیدهای اعتبارسنجی، یکتایی کلید idempotency سفارش و جلوگیری از ثبت دوباره شناسه تراکنش است.
- migration هنوز روی هیچ دیتابیسی اجرا نشده؛ `DATABASE_URL` تنظیم نشده است و اجرای آن روی production ممنوع است تا ابتدا در PostgreSQL آزمایشی بررسی شود.
- بررسی syntax فایل‌های migration با `compileall` موفق بود. اجرای pytest و تست واقعی Alembic هنوز مسدود است چون pip و python3-venv روی میزبان نصب نیستند.
- **قدم بعدی:** ساخت محیط تست ایزوله و PostgreSQL موقت، اجرای unit tests و migration در محیط آزمایشی، سپس بررسی metadata و ایمن‌سازی routeهای admin پیش از پیاده‌سازی سفارش و پرداخت.

### 2026-10-15: دیباگ اجرایی Store Backend

- تست‌ها در کانتینر موقت Python 3.12 اجرا شدند تا به Python سیستم و سرویس‌های موجود دست نزنیم: اجرای اولیه `pytest -q` نتیجه **5 passed** داد؛ پس از افزودن تست‌های دائمی health، اجرای نهایی `pytest -q` نتیجه **7 passed** داد.
- یک PostgreSQL آزمایشی موقت و جدا از دیتابیس پنل بالا آمد؛ `alembic upgrade head` موفق شد و `alembic check` نتیجه `No new upgrade operations detected` داد. جدول‌های `store_plans`، `store_orders` و `alembic_version` تأیید شدند.
- تست یکپارچه واقعی روی PostgreSQL آزمایشی: `/health/live` پاسخ 200؛ `/health/ready` پس از اجرای `SELECT 1` پاسخ 200؛ `GET /api/v1/store/plans` فقط پلن فعال را برگرداند و `panel_template_id` را افشا نکرد.
- اصلاح باگ readiness: قبلاً فقط وجود `DATABASE_URL` بررسی می‌شد و دیتابیس قطع‌شده هم می‌توانست ready گزارش شود. حالا اتصال واقعی DB با `SELECT 1` بررسی و در خطا `503 database_unavailable` برگردانده می‌شود.
- وضعیت متن قرارداد API اصلاح شد تا با وجود route عمومی و migration اولیه تناقض نداشته باشد.
- کانتینر و شبکه دیتابیس آزمایشی پس از تست حذف شدند؛ هیچ دیتابیس production یا کانتینر فعال تغییر نکرد.
- syntax برنامه، migration و تست‌ها با `compileall` موفق است؛ تست نهایی شامل 7 تست واحد است. هنوز پرداخت، احراز هویت مشتری، پنل ادمین و provisioning امن پیاده‌سازی نشده‌اند؛ سرویس برای production آماده نیست.
- **قدم بعدی:** افزودن تست‌های دائمی برای کاتالوگ و readiness، سپس پیاده‌سازی auth و CRUD پلن‌های admin قبل از سفارش/پرداخت. ابتدا باید محل Git رسمی Store Backend تعیین شود؛ مسیر فعلی خارج از ریشه Git اپ اندروید است و تغییری push نشده است.


### 2026-10-15: شروع API مدیریت پلن‌های Store

- `Settings` حالا `ADMIN_API_TOKEN` مستقل دارد؛ این توکن با `PANEL_API_KEY` یکی نیست و برای Bearer authentication استفاده می‌شود.
- routeهای `GET /api/v1/admin/plans`، `POST /api/v1/admin/plans` و `PATCH /api/v1/admin/plans/{id}` اضافه شدند. حذف فیزیکی نداریم؛ غیرفعال‌سازی با `is_active=false` انجام می‌شود. خطای slug تکراری به 409 تبدیل می‌شود.
- schemaهای admin/create/patch اضافه شدند؛ slug محدود به حروف کوچک انگلیسی، عدد و خط تیره؛ currency سه‌حرفی و uppercase؛ فیلدهای عددی محدود شده‌اند.
- `.env.example` و README با تنظیمات و محدودیت‌های endpointهای admin به‌روز شدند. هیچ secret واقعی نوشته نشده است.
- `python3 -m compileall -q app migrations tests` موفق بود. اجرای pytest در کانتینر موقت در حال بررسی است؛ نتیجه نهایی هنوز تأیید نشده. تست CRUD با PostgreSQL آزمایشی و تست احراز هویت هنوز باید اجرا و اضافه شوند.
- Backend هنوز Git repository مستقل ندارد؛ هیچ commit یا push انجام نشده. API admin را تا افزودن audit logging، rate limiting و تست‌های یکپارچه روی شبکه عمومی expose نکن.
- **قدم بعدی:** تأیید اجرای تست‌ها، افزودن تست‌های auth و schema، تست CRUD با PostgreSQL موقت، سپس مدیریت mapping قالب‌های پنل. پرداخت و provisioning هنوز پیاده‌سازی نشده‌اند.

- تکمیل همین مرحله: پنج تست جدید برای auth توکن ادمین، نرمال‌سازی نام/ارز، رد کردن slug نامعتبر و PATCH جزئی اضافه شدند. اجرای مجدد در کانتینر Python 3.12 نتیجه **12 passed in 0.84s** داد و `compileall` هم موفق بود.


### 2026-10-15: API فهرست قالب‌های پنل

- endpoint محافظت‌شده `GET /api/v1/admin/panel/templates` اضافه شد. فقط شناسه، نام و توضیح قالب برمی‌گردد؛ payload خام پنل یا فیلدهای دیگر به مصرف‌کننده API داده نمی‌شود.
- خطاهای تنظیمات اتصال پنل با 503 و خطاهای upstream با 502 برگردانده می‌شوند؛ جزئیات خام پاسخ پنل در API افشا نمی‌شود.
- دو تست جدید اضافه شد: بسته‌بودن دسترسی در نبود توکن ادمین و allowlist خروجی قالب‌ها. اجرای مجدد در کانتینر موقت Python 3.12: **14 passed in 0.77s**؛ `compileall` نیز موفق بود.
- API واقعی پنل هنوز از این endpoint فراخوانی نشده؛ در نتیجه شکل دقیق پاسخ `/api/user_template/s` و دسترسی کلید واقعی هنوز تأیید نشده‌اند. هیچ تنظیم یا داده‌ای در پنل production تغییر نکرده است.
- **قدم بعدی:** ساخت تست یکپارچه CRUD با PostgreSQL موقت، سپس صفحه ادمین و endpoint امن تست اتصال پنل؛ قبل از هر deployment باید توکن مستقل ادمین و کلید محدوددسترسی پنل روی سرور پیکربندی شوند.

- endpoint محافظت‌شده `POST /api/v1/admin/panel/test-connection` هم اضافه شد؛ فقط وضعیت اتصال و پیام امن را برمی‌گرداند و credential یا پاسخ خام پنل را نمایش نمی‌دهد. تست route با mock اضافه شد.
- اجرای نهایی تست‌ها پس از این تغییر: **15 passed in 0.75s**؛ `compileall` موفق بود. این‌ها unit tests هستند و به معنی تأیید اتصال زنده به پنل نیستند.


### 2026-10-15: داشبورد وب ادمین Store

- صفحه واقعی داشبورد در `store-backend/app/static/admin.html` ساخته شد و route جدید `GET /admin` در `app/main.py` آن را با `Cache-Control: no-store` سرو می‌کند.
- قابلیت‌ها: ورود با `ADMIN_API_TOKEN` مستقل (ذخیره در `sessionStorage` همان نشست)، تست read-only اتصال پنل، دریافت قالب‌ها، ایجاد پلن فروشگاه، مشاهده پلن‌ها و فعال/غیرفعال‌سازی با PATCH. کلید پنل در رابط کاربری وارد یا نمایش داده نمی‌شود.
- تست جدید route داشبورد اضافه شد؛ اجرای کامل در کانتینر موقت Python 3.12: `compileall` موفق و **16 passed in 0.88s**.
- JavaScript صفحه با `node --check` بررسی شد و بدون خطای syntax بود.
- README به‌روز شد تا route داشبورد و وضعیت migration را دقیق توضیح دهد.
- محدودیت فعلی: اتصال واقعی به API پنل هنوز تأیید نشده، تست CRUD روی PostgreSQL موقت باید اضافه شود، و endpointهای سفارش/پرداخت/provisioning هنوز وجود ندارند. هیچ deployment، تغییر دیتابیس production، تغییر پنل یا push گیت‌هاب انجام نشده است.
- نکته امنیتی: پیش از انتشار عمومی باید `ADMIN_API_TOKEN` قوی تنظیم شود و دسترسی داشبورد از reverse proxy/VPN/IP allowlist محدود شود. کلید پنل قبلی که در گفت‌وگوی قبلی افشا شده بود نباید دوباره استفاده شود و باید rotate/revoke شود.


### 2026-10-15: تست یکپارچه CRUD با PostgreSQL موقت

- یک شبکه و کانتینر PostgreSQL 16 کاملاً موقت ساخته شد؛ migration با `alembic upgrade head` موفق شد. تست‌ها از کانتینر Python جدا به همین دیتابیس آزمایشی متصل شدند.
- سناریوهای واقعی API با PostgreSQL پاس شدند: health، ساخت پلن، فهرست ادمین، فهرست عمومی بدون افشای `panel_template_id`، رد slug تکراری با HTTP 409، PATCH برای غیرفعال‌سازی و حذف پلن غیرفعال از فهرست عمومی، رد درخواست ادمین بدون توکن با HTTP 401 و سرو شدن داشبورد.
- نتیجه: `PASS: live PostgreSQL migration, create/list/public allowlist/duplicate slug/PATCH deactivate/auth/dashboard`.
- کانتینر و شبکه تست در `trap` پاک شدند؛ هیچ دیتابیس production، کانتینر فعال یا تنظیم پنل تغییر نکرد.
- بررسی مستندات رسمی PasarGuard نیز تأیید می‌کند مسیر ایجاد کاربر از قالب `POST /api/user/from_template` و بدنه شامل `user_template_id` و `username` است. اتصال واقعی همچنان تا تنظیم یک API key تازه و کم‌دسترسی در محیط سرور عمداً اجرا نشده است.


### 2026-10-16: بررسی مرحله بعد و محدودیت ابزار
- بازخوانی مجدد سورس نشان داد endpoint فهرست قالب‌ها در `app/routes/admin.py` هنوز برای `limit/offset` از `Query(ge=..., le=...)` استفاده نمی‌کند؛ در نتیجه مقدار خارج از محدوده به‌جای پاسخ کنترل‌شده 422 ممکن است به خطای داخلی تبدیل شود. این اصلاح در این نوبت به‌دلیل ردشدن درخواست ویرایش توسط کنترل ایمنی ابزار اعمال نشد.
- تست اتصال پنل واقعی همچنان به API key تازه و کم‌دسترسی نیاز دارد؛ هیچ کلید یا credentialی در این مرحله استفاده نشده است.
- سفارش و پرداخت را تا پیاده‌سازی هویت معتبر مشتری و callback امضاشدهٔ درگاه نباید عمومی کرد. افزودن endpoint ساده‌ای که از مشتری `customer_id` بگیرد یا با درخواست معمولی سفارش را paid کند، ناامن است.


### 2026-10-16: رفع باگ pagination و تست مجدد
- در `store-backend/app/routes/admin.py` پارامترهای endpoint قالب‌ها به FastAPI `Query` منتقل شدند: `limit` بین 1 و 200 و `offset` بین 0 و 1,000,000 محدود است.
- در `store-backend/tests/test_admin.py` تست HTTP اضافه شد که `limit=0`، `limit=201` و `offset=-1` را با توکن ادمین معتبر می‌فرستد و انتظار HTTP 422 دارد.
- اجرای مجدد داخل کانتینر موقت Python 3.12: `compileall` موفق و **17 passed in 0.81s**. این اصلاح تست‌شده است.
- هیچ deployment یا تغییر production انجام نشد؛ اتصال زنده به پنل همچنان منتظر API key تازه با حداقل دسترسی است.

- تست adapter نیز اضافه شد: `create_user_from_template` با MockTransport بررسی می‌کند که درخواست فقط از سمت سرور به `POST /api/user/from_template` با `X-Api-Key` و فیلدهای مستند `username`, `user_template_id`, `note` ارسال شود. هیچ درخواست واقعی به پنل ارسال نشد.
- اجرای کامل پس از افزودن این تست: `compileall` موفق و **18 passed in 0.79s**.


### 2026-10-16: دیباگ پاسخ خطای Panel API و ریدایرکت‌ها

- **کار انجام‌شده:** باگ گزارش وضعیت اتصال اصلاح شد؛ قبلاً خطای HTTP 401 و 403 هر دو به‌صورت 403 گزارش می‌شدند. حالا `PanelRequestError` وضعیت HTTP upstream را به‌صورت ساختاریافته نگه می‌دارد و `test_connection()` همان status code را برمی‌گرداند، بدون افشای body خام پنل.
- **سخت‌سازی/تست:** تست پارامتری برای پاسخ‌های 401، 403، 404، 429 و 500 اضافه شد و بررسی می‌کند متن خصوصی پاسخ upstream در پیام خروجی افشا نشود. تست دیگری تأیید می‌کند ریدایرکت HTTP دنبال نمی‌شود و درخواست به host دیگری منتقل نمی‌شود.
- **فایل‌های تغییرکرده:** `store-backend/app/panel/client.py`، `store-backend/tests/test_panel_client.py`، و همین Work Log.
- **تست واقعی:** در کانتینر موقت `python:3.12-slim`، `python -m compileall -q app migrations tests` موفق شد و `pytest -q` نتیجه **24 passed in 0.86s** داد. کانتینر با `--rm` اجرا شد؛ هیچ وابستگی روی Python سیستم نصب نشد.
- **محدوده:** فقط سورس و تست‌ها تغییر کردند. هیچ درخواست به پنل واقعی، deployment، تغییر DB، تغییر کانتینر فعال یا push گیت‌هاب انجام نشد.
- **ریسک/باقی‌مانده:** endpoint اتصال هنوز یک probe فقط‌خواندنی است؛ موفقیت تست mock، دسترسی کلید واقعی را ثابت نمی‌کند. برای تست زنده باید API key جدید با حداقل permission ساخته و از محیط امن سرور تزریق شود. کلید افشاشده قبلی نباید استفاده شود.
- **قدم بعدی:** بازبینی امنیتی مدل سفارش و migration (قیدهای وضعیت و idempotency)، سپس تست‌های منفی بیشتر برای adapter و schemaها. قبل از سفارش/پرداخت عمومی، هویت مشتری و webhook امضاشده درگاه باید طراحی و پیاده‌سازی شوند.


### 2026-10-16: تکمیل بررسی رفتار HTTP redirect در adapter

- پس از بازبینی تست قبلی، مشخص شد redirect به‌درستی دنبال نمی‌شود، اما پاسخ اتصال status code مشخصی برای 3xx گزارش نمی‌کرد. این رفتار شفاف‌تر شد: حالا پاسخ 3xx با پیام امن و همان status code (برای نمونه 302) رد می‌شود.
- تست redirect به‌روزرسانی شد تا هم عدم follow، هم عدم درخواست به host مقصد و هم گزارش `302` را تأیید کند.
- اجرای مجدد در کانتینر موقت Python 3.12: `compileall` موفق و **24 passed in 0.85s**؛ exit code برابر 0.
- **فایل‌ها:** `store-backend/app/panel/client.py` و `store-backend/tests/test_panel_client.py`.
- **محدوده:** تغییرات سورس و تست؛ بدون تماس با پنل زنده، بدون deployment و بدون تغییر در سرویس‌های production.
- **قدم بعدی:** ادامه ممیزی مدل‌ها و migration سفارش برای محدودیت‌های وضعیت و قیدهای دیتابیس؛ پیش از پیاده‌سازی endpoint سفارش باید هویت مشتری و قرارداد پرداخت امن مشخص شوند.


### 2026-10-16: بازبینی اولیه integrity مدل سفارش

- **یافته:** فیلد `store_orders.status` در دیتابیس فعلی از نوع رشته است و constraint دیتابیسی برای محدودکردن آن به وضعیت‌های تعریف‌شده در `OrderStatus` ندارد. این می‌تواند باگ داده‌ای ایجاد کند، هرچند فعلاً endpoint عمومی سفارش وجود ندارد.
- **اقدام:** افزودن constraint و migration جدید بررسی شد، اما نوشتن فایل migration توسط کنترل ایمنی ابزار مسدود شد. تغییر آزمایشی مدل که پیش از آن اعمال شده بود، فوراً برگشت داده شد تا مدل و migration ناسازگار باقی نمانند.
- **وضعیت نهایی:** هیچ migration جدیدی به‌عنوان تکمیل‌شده ثبت نمی‌شود و مدل فعلی به وضعیت قبل از این تلاش برگشته است. این مورد هنوز باز است.
- **محدوده:** دیتابیس یا سرویس production تغییر نکرد؛ هیچ workaround یا مسیر جایگزینی برای دور زدن محدودیت ابزار استفاده نشد.
- **قدم بعدی:** بعد از فراهم‌شدن مسیر مجاز و قابل تأیید برای افزودن migration، constraint وضعیت سفارش را در migration مستقل پیاده‌سازی و روی PostgreSQL موقت با ورودی معتبر/نامعتبر تست کنیم.


### 2026-10-16: سخت‌سازی احراز هویت Admin و اعتبارسنجی schema

- **یافته:** بررسی کد `require_admin` نشان داد scheme هدر Authorization با مقایسه حساس به بزرگی/کوچکی حروف شناسایی می‌شد؛ این رفتار برای HTTP auth scheme غیرضروری سخت‌گیرانه بود.
- **تغییر:** parser هدر حالا scheme را case-insensitive می‌خواند و همچنان فقط `Bearer` را قبول می‌کند. credential خالی، scheme اشتباه و هدر ناقص همچنان با 401 رد می‌شوند؛ مقایسه secret با `secrets.compare_digest` حفظ شد.
- **تست‌های افزوده:** پذیرش `bearer` و `BEARER`؛ رد کردن هدر بدون scheme، `Basic`، و Bearer بدون credential؛ رد currency نامعتبر و name خالی در `StorePlanPatch`.
- **فایل‌ها:** `store-backend/app/routes/admin.py` و `store-backend/tests/test_admin.py`.
- **اعتبارسنجی واقعی:** `python3 -m compileall -q .../app .../migrations .../tests` با exit code 0 تکمیل شد. اجرای مجدد کامل pytest در کانتینر موقت توسط کنترل ایمنی ابزار مسدود شد؛ بنابراین برای این تغییرات نتیجه pytest جدید ادعا نمی‌شود. آخرین نتیجه pytest تأییدشده مربوط به مرحله قبل است: 24 passed؛ تست‌های تازه هنوز نیاز به اجرای کامل دارند.
- **محدوده:** سورس و تست‌ها تغییر کردند؛ هیچ deployment، تماس زنده با پنل، یا تغییر دیتابیس انجام نشد.
- **قدم بعدی:** اجرای تست‌های جدید در محیط تست مجاز؛ سپس بازگشت به integrity سفارش/migration و بررسی رفتارهای concurrency قبل از ساخت API سفارش و پرداخت.


### 2026-10-16: ادامه پروژه — integrity سفارش و بررسی build اندروید

- **فاز:** سخت‌سازی مدل و migration فروشگاه؛ بررسی امکان build کلاینت Android.
- **کارهای انجام‌شده:**
  - در `store-backend/app/models.py` قید `ck_store_order_status_valid` اضافه شد تا وضعیت سفارش فقط یکی از `pending_payment`, `paid_pending_provisioning`, `fulfilled`, `cancelled`, `failed`, `refunded` باشد.
  - migration مستقل `store-backend/migrations/versions/0002_order_status_constraint.py` ایجاد شد. پیش از افزودن constraint، وضعیت‌های تاریخی ناشناخته را بررسی می‌کند و در صورت وجود، بدون بازنویسی خودکار داده‌ها migration را fail می‌کند.
  - README به‌روزرسانی شد تا migration دوم و محدودیت عدم آماده‌بودن سفارش/پرداخت برای production را توضیح دهد.
- **فایل‌های تغییرکرده:** `store-backend/app/models.py`, `store-backend/migrations/versions/0002_order_status_constraint.py`, `store-backend/README.md`, این فایل گزارش.
- **تست‌ها و نتیجه واقعی:**
  - اجرای suite در کانتینر موقت Python 3.12: **30 passed in 0.86s**؛ `compileall` موفق بود.
  - روی PostgreSQL 16 موقت: `alembic upgrade head` موفق، `alembic check` نتیجه `No new upgrade operations detected` داد.
  - درج سفارش با `status=invalid_status` مستقیماً در PostgreSQL رد شد؛ تست با پیام `PASS: PostgreSQL rejects invalid order status` و exit code صفر تمام شد.
  - کانتینر و شبکه تست پس از پایان پاک شدند؛ هیچ دیتابیس production یا سرویس پنل تغییر نکرد.
  - بررسی build اندروید با `./gradlew --version` متوقف شد، چون روی دستگاه `CLY914129` نه Java و نه `JAVA_HOME` تنظیم شده است. هیچ بسته سیستمی نصب نشد و build اندروید ادعا نمی‌شود.
- **موارد مسدود/ریسک‌ها:**
  - کلاینت Android هنوز به Store Backend وصل نشده و build واقعی Android انجام نشده است.
  - احراز هویت مشتری، سفارش، درگاه پرداخت، webhook امضاشده، ledger کیف پول و provisioning امن هنوز پیاده‌سازی نشده‌اند؛ این سرویس را نباید checkout عمومی یا production-ready دانست.
  - تست اتصال به پنل واقعی همچنان به API key جدید و کم‌دسترسی نیاز دارد؛ کلید افشاشده قبلی نباید استفاده شود.
  - `store-backend` بیرون از ریشه Git کلاینت است و repository مستقل/مقصد انتشار آن هنوز تعیین نشده؛ هیچ push یا deployment انجام نشد.
- **قدم بعدی:** ابتدا تعیین و ثبت قرارداد هویت مشتری و منبع معتبر user identity، سپس تعریف adapter پرداخت و callback امضاشده با idempotency، افزودن تست‌های یکپارچه؛ بعد از آن ادغام UI/API در کلاینت و آماده‌سازی محیط Java/Android SDK ایزوله برای build واقعی. تا آن زمان هیچ مسیر پرداخت یا فعال‌سازی اشتراک نباید عمومی شود.


### 2026-10-16: دیباگ جامع مرحله‌ای و شروع برندینگ کلاینت

- **فاز:** بازبینی مجدد TODO، تست رگرسیون Backend، بررسی بسته‌بندی Android و اصلاح نام نمایشی.
- **بازبینی وضعیت پروژه:**
  - سورس Android در /opt/manubisguard-android/android روی branch dev با HEAD برابر 30ff3451 است. این repository فقط کلاینت را پوشش می‌دهد؛ مسیر store-backend بیرون از Git repository است و در وضعیت فعلی commit/push نشده.
  - روی میزبان CLY914129، java، JAVA_HOME، ANDROID_HOME و ANDROID_SDK_ROOT موجود نیستند. بنابراین Gradle/Qt Android build کامل در این محیط قابل اجرا نیست و APK تولید یا ادعا نشده.
  - بررسی کد تأیید کرد که مسیر پرداخت Google Play/Apple در سورس Amnezia موجود است، اما این مسیر معادل فروشگاه مستقیم ManubisGuard نیست. قرارداد Gateway پیش‌فرض upstream هم با API پنل ManubisGuard یکی نیست؛ تغییر ساده URL یا ارسال API key پنل از اپ ناامن و ناسازگار خواهد بود.
- **تست‌های Backend و بازبینی ایمنی:**
  - اجرای مجدد کامل در کانتینر موقت Python 3.12: compileall موفق، 30 passed in 0.80s.
  - JavaScript داشبورد با node --check بررسی شد و بدون خطای syntax بود.
  - XML فایل‌های AndroidManifest.xml و res/values/strings.xml با parser پایتون معتبر تشخیص داده شدند.
  - git diff --check روی سورس Android بدون خطا بود.
  - اسکن الگوهای متداول کلید/secret در سورس Backend و فایل نمونه env، هیچ تطبیقی پیدا نکرد؛ این اسکن جایگزین secret scanner جامع نیست.
  - migrationهای فروشگاه قبلاً در همین نشست روی PostgreSQL 16 موقت اجرا شدند؛ alembic upgrade head و alembic check موفق بودند و PostgreSQL وضعیت سفارش نامعتبر را رد کرد. دیتابیس production تغییر نکرد.
- **برندینگ انجام‌شده:**
  - مقدار پیش‌فرض CLIENT_APPLICATION_NAME به Manubis Guard تغییر کرد، بدون تغییر نام سازمان داخلی QSettings یا namespace Kotlin برای جلوگیری از مهاجرت ناخواسته تنظیمات.
  - نام اپ در Android Manifest، عنوان پنجره اصلی QML، پیام‌های permission/notification، عنوان biometric prompt، Quick Settings tile، صفحه About و چند متن قابل مشاهده مربوط به export/share به Manubis Guard تغییر کرد.
  - این تغییرات فعلاً نام و متن‌های نمایشی‌اند؛ آیکون هنوز آیکون upstream است، Android applicationId هنوز org.amnezia.vpn است، و build روی دستگاه واقعی تأیید نشده. بنابراین هنوز برندینگ و بسته مستقل آماده انتشار محسوب نمی‌شود.
- **فایل‌های تغییرکرده در repository Android:**
  - client/android/AndroidManifest.xml
  - client/android/res/values/strings.xml
  - client/android/src/org/amnezia/vpn/AmneziaTileService.kt
  - client/android/src/org/amnezia/vpn/AuthActivity.kt
  - client/android/src/org/amnezia/vpn/ServiceNotification.kt
  - client/cmake/branding/common.cmake
  - client/ui/qml/main2.qml
  - client/ui/qml/Pages2/PageShareConnection.qml
  - client/ui/qml/Pages2/PageSettingsAbout.qml
  - client/ui/qml/Pages2/PageSettingsApiSubscriptionKey.qml
  - client/ui/qml/Pages2/PageSettingsApiNativeConfigs.qml
  - client/ui/qml/Pages2/PageShare.qml
  - client/ui/qml/Pages2/PageSettings.qml
  - client/ui/qml/Pages2/PageSettingsServerData.qml
  - client/ui/qml/Pages2/PageSettingsApplication.qml
  - client/ui/qml/Pages2/PageSetupWizardConfigSource.qml
  - client/ui/qml/Pages2/PageSettingsBackup.qml
- **موارد مسدود / کارهای لازم قبل از ادعای تکمیل:**
  - UI فروشگاه داخل اپ هنوز ساخته نشده و به APIهای مشتری/سفارش که هنوز وجود ندارند متصل نیست.
  - auth مشتری، پرداخت و webhook، wallet ledger، provisioning/idempotency و retry امن هنوز پیاده‌سازی نشده‌اند.
  - Backend هنوز deployment manifest/Docker image production، rate limit و audit logging کامل ندارد؛ dashboard را نباید مستقیم روی اینترنت عمومی باز کرد.
  - کلید پنل جدید با حداقل دسترسی برای تست زنده فراهم نشده؛ کلید افشاشده قبلی نباید استفاده شود.
  - applicationId و authorityهای Android هنوز upstream هستند. تغییرشان باید به‌صورت یک مرحله جدا با بررسی manifest/intent/Qt deployment و build واقعی انجام شود تا import config و VPN service خراب نشوند.
  - آیکون و assetهای برند اختصاصی هنوز جایگزین نشده‌اند.
- **قدم بعدی:** تعیین هویت و روش ورود مشتری و قرارداد اشتراک/پلن؛ سپس پیاده‌سازی API احرازشده و adapter provisioning با تست‌های منفی/idempotency. هم‌زمان محیط Qt/Android SDK ایزوله فراهم شود تا تغییرات branding و package ID با build واقعی و نصب آزمایشی اعتبارسنجی شوند. سپس UI فروشگاه به‌صورت صفحه مستقل به کلاینت اضافه شود؛ پرداخت تا انتخاب provider و اعتبارسنجی webhook نباید fake یا عمومی شود.


### 2026-10-16: نتیجه نهایی تست رگرسیون پس از تغییرات برندینگ

- اجرای نهایی Backend در کانتینر موقت Python 3.12: 30 passed in 0.83s و compileall موفق.
- AndroidManifest.xml و strings.xml دوباره parse شدند و معتبر بودند.
- node --check روی JavaScript داشبورد موفق؛ git diff --check روی کلاینت موفق.
- 17 فایل کلاینت Android تغییر محلی دارند؛ هیچ commit یا push انجام نشده و هیچ APK تولید نشده است.
- این نتیجه صحت تست‌های Backend و چند بررسی ایستا را تأیید می‌کند؛ جایگزین build واقعی Qt/Android، تست نصب روی دستگاه، یا تست end-to-end فروشگاه نیست.


## نقشه راه بازتنظیم‌شده پروژه — 2026-10-16

این بخش، ترتیب اجرایی فعلی را مشخص می‌کند. تیک فقط پس از اجرای واقعی تست و ثبت نتیجه زده شود.

### فاز A — تثبیت قرارداد محصول و API پنل [در حال انجام]
- [x] ثبت محدوده محصول و ممیزی اولیه کلاینت/پنل.
- [x] ثبت قرارداد اولیه Store API و شناسایی routeهای user/template در سورس پنل.
- [ ] نهایی‌کردن جریان‌های کاربر: ورود/ثبت‌نام، مهمان/ورود لینک اشتراک، خرید و تمدید.
- [ ] تکمیل mapping پلن فروشگاه به template/plan پنل، مصرف، تاریخ انقضا و subscription link با نمونه پاسخ واقعی و بدون افشای secret.
- [ ] ساخت/تأیید API key تازه با کمترین permission و اجرای تست فقط‌خواندنی روی پنل واقعی.
- **خروجی/معیار عبور:** قرارداد نسخه‌دار با request/response و خطاهای مشخص؛ mapping واقعی و تأییدشده؛ بدون کلید داخل اپ یا Git.

### فاز B — تکمیل Store Backend امن [بعدی، اولویت اول]
- [x] اسکلت FastAPI، health endpoints، مدل‌های پایه plan/order و migrationهای اولیه.
- [x] کاتالوگ عمومی پلن‌ها و داشبورد مدیریتی اولیه.
- [x] تست‌های فعلی: 30 passed؛ migration روی PostgreSQL موقت بررسی شده است.
- [ ] طراحی و پیاده‌سازی هویت مشتری و session/token؛ تعیین account flow و مالکیت اشتراک.
- [ ] تکمیل Panel Adapter برای ایجاد/خواندن/تمدید اشتراک، دریافت usage/expiry و بازگرداندن لینک اشتراک؛ خطاهای پنل باید امن و قابل retry باشند.
- [ ] پیاده‌سازی order lifecycle، idempotency واقعی و کنترل race/concurrency.
- [ ] انتخاب درگاه پرداخت و پیاده‌سازی callback/webhook با امضای معتبر، مبلغ/ارز تطبیق‌یافته و جلوگیری از replay؛ تا آن زمان پرداخت واقعی فعال نشود.
- [ ] wallet/ledger فقط در صورت تأیید نیاز محصول؛ هر تغییر موجودی با ledger حسابرسی‌پذیر.
- [ ] rate limit، audit log، مدیریت session/role و تست جداسازی داده‌های مشتری.
- **خروجی/معیار عبور:** API مستند و تست‌شده برای auth، plans, subscription, order, payment status؛ فعال‌سازی فقط از سمت سرور بعد از تأیید پرداخت معتبر؛ تست تکرار درخواست و شکست پنل.

### فاز C — سخت‌سازی Admin Dashboard و تنظیمات [در حال انجام]
- [x] داشبورد اولیه و مدیریت ابتدایی پلن/قالب.
- [-] ورود مدیر با bearer token مشترک پیاده‌سازی شده؛ نقش‌های مجزا، session server-side و rate limiting هنوز باقی است.
- [x] تنظیم Base URL پنل و credential رمز‌شده با Fernet سمت سرور؛ secret کامل هرگز از API برگردانده نمی‌شود.
- [-] endpoint تست اتصال و دریافت قالب‌ها پیاده‌سازی و mock-test شده؛ تست پنل واقعی، mapping کامل پلن‌ها، سفارش/provisioning و audit log تغییرات هنوز باقی است.
- [-] هدرهای امنیتی و cache control فعال‌اند؛ HTTPS reverse proxy، firewall/allowlist، rate limiting و audit log قبل از دسترسی عمومی لازم‌اند.
- **خروجی/معیار عبور:** داشبورد staging محدود به شبکه قابل استفاده است؛ برای production هنوز تمام موارد باقی‌مانده باید بسته شوند.

### فاز D — محیط ساخت و تثبیت برند Android [قابل اجرا موازی]
- [x] تغییرات نام نمایشی در 17 فایل؛ XML و diff check موفق.
- [ ] آماده‌سازی محیط build ایزوله با نسخه‌های سازگار Qt، JDK، Android SDK و NDK؛ ثبت نسخه‌ها و دستور build قابل تکرار.
- [ ] build اولیه از سورس بدون تغییر منطق VPN برای پیدا کردن وابستگی‌ها و خطاهای موجود.
- [ ] انتخاب applicationId نهایی و تغییر کنترل‌شده package/authorities/deep links پس از بررسی همه referenceها.
- [ ] جایگزینی icon، splash و assets با برند Manubis Guard.
- [ ] build دوباره و تست نصب/ارتقا، permissionها، VPN service، import config و اتصال پایه.
- **خروجی/معیار عبور:** APK واقعی ساخته و روی دستگاه/شبیه‌ساز نصب شده؛ هسته VPN و import کانفیگ regression نداشته باشند.

### فاز E — طراحی و ادغام Store داخل اپ [پس از قرارداد API و build پایه]
- [ ] طراحی/پیاده‌سازی Home/Dashboard: وضعیت اتصال، سرور، حجم و انقضا در صورت پشتیبانی داده.
- [ ] صفحات ورود/ثبت‌نام و حالت مهمان/واردکردن subscription link.
- [ ] فهرست پلن‌ها، جزئیات، خرید، تمدید و وضعیت سفارش.
- [ ] کیف پول/تاریخچه فقط در صورت پشتیبانی backend و قرارداد تجاری نهایی.
- [ ] زبان فارسی و انگلیسی، RTL، loading/empty/error states و دسترس‌پذیری.
- [ ] استفاده از TLS و session مشتری؛ هیچ panel API key یا secret مدیریتی داخل APK نباشد.
- **خروجی/معیار عبور:** جریان کاربر از ورود تا مشاهده اشتراک و ثبت سفارش در محیط آزمایشی end-to-end کار کند.

### فاز F — تست امنیتی و پذیرش End-to-End
- [ ] unit/integration tests برای auth، جداسازی کاربران، panel adapter، order/payment/provisioning.
- [ ] تست webhook جعلی/امضای غلط، replay، مبلغ نادرست، پرداخت تکراری و سفارش هم‌زمان.
- [ ] تست قطع/timeout پنل و retry بدون ساخت اشتراک تکراری.
- [ ] تست secret leakage در log/response/build artifact.
- [ ] تست نصب، اجرای VPN، قطع/وصل، import اشتراک، تمدید و خطاهای شبکه.
- **خروجی/معیار عبور:** همه تست‌ها pass؛ گزارش باگ‌های باز و ریسک‌های پذیرفته‌شده مشخص.

### فاز G — انتشار آزمایشی و استقرار امن
- [ ] repository مستقل و محل انتشار مشخص برای `store-backend`؛ تعیین سیاست commit/tag/release.
- [x] Dockerfile، Compose، نمونه env، health checks و GitHub Actions workflow آماده؛ image واقعی build شده است.
- [-] stack محلی ایزوله با secrets تصادفی و loopback-only port اجرا و smoke-test شد؛ HTTPS reverse proxy، backup/restore، rollback مستند و staging پایدار هنوز باقی است.
- [ ] خرید آزمایشی end-to-end با درگاه sandbox و تأیید فعال‌سازی واقعی در پنل.
- [ ] تولید APK آزمایشی، changelog، دستور نصب و راهنمای مدیر.
- [ ] انتشار production فقط پس از عبور از معیارهای امنیتی و تستی بالا.
- **خروجی/معیار عبور:** نسخه beta قابل نصب، backend مانیتورشده، rollback مستند و جریان خرید تأییدشده.

### ترتیب اجرای پیشنهادی
1. فاز A را ببندیم: قرارداد مشتری و mapping واقعی پنل.
2. فاز B را پیاده‌سازی کنیم: auth + subscription adapter + order lifecycle؛ پرداخت را فقط بعد از انتخاب provider و پیاده‌سازی webhook معتبر فعال کنیم.
3. فاز D را موازی شروع کنیم: build پایه و برندینگ کامل، بدون دستکاری غیرضروری هسته VPN.
4. فاز C و سپس E را تکمیل کنیم: داشبورد امن و فروشگاه داخل اپ.
5. فاز F را کامل اجرا کنیم.
6. فاز G: staging، beta و بعد production.

### موانع فعلی مهم
- محیط فعلی CLY914129 فاقد Java/Android SDK/NDK/Qt build setup تأییدشده است؛ APK هنوز ساخته نشده.
- API key جدید و کم‌دسترسی برای تست زنده پنل موجود/تأییدشده نیست.
- provider پرداخت و سیاست قیمت/ارز/پرداخت هنوز نهایی نشده است.
- `store-backend` خارج از Git repository کلاینت قرار دارد و مقصد repo/release آن باید تعیین شود.
- تغییرات برندینگ Android محلی و commit نشده‌اند؛ هیچ push یا production deployment انجام نشده است.


### 2026-10-16: تکمیل ویرایش پلن در داشبورد ادمین

- **فاز:** C — بهبود مدیریت پلن‌های فروشگاه.
- **کارهای انجام‌شده:** در داشبورد ادمین، عملیات ویرایش کامل پلن به جدول اضافه شد؛ فرم ایجاد اکنون در حالت ویرایش همان فیلدها را پر می‌کند و با `PATCH /api/v1/admin/plans/{id}` تغییرات را ذخیره می‌کند. دکمه لغو ویرایش اضافه شد و فرم پس از ذخیره/لغو به حالت ایجاد بازمی‌گردد. وضعیت ویرایش قبل از ذخیره صریح نمایش داده می‌شود. این تغییر فقط اطلاعات کاتالوگ فروشگاه را تغییر می‌دهد و ادعای فعال‌سازی اشتراک مشتری ندارد.
- **فایل تغییرکرده:** `store-backend/app/static/admin.html`.
- **تست‌های واقعی:** اسکریپت inline با `node --check` معتبر است؛ `git diff --check` روی کلاینت بدون خطا؛ `python -m compileall -q app migrations tests` موفق؛ suite کامل در کانتینر موقت Python 3.12: **30 passed in 0.81s**.
- **محدوده ایمنی:** فقط فایل داشبورد محلی تغییر کرد؛ هیچ production deploy، دیتابیس production، پنل VPN یا سرویس فعال دستکاری نشد. هیچ commit/push انجام نشد.
- **محدودیت باقی‌مانده:** مرورگر واقعی و API زنده با توکن مدیر/پنل در این مرحله آزمایش نشده‌اند. احراز هویت مشتری، سفارش/پرداخت و provisioning هنوز وجود ندارند. داشبورد همچنان نباید بدون سخت‌سازی و HTTPS/rate limit/audit log در معرض اینترنت عمومی قرار بگیرد.
- **قدم بعدی:** تست قراردادی CRUD پلن روی دیتابیس آزمایشی و اضافه‌کردن قابلیت‌های پیکربندی عمومی فروشگاه (عنوان، توضیحات، ارز پیش‌فرض و لینک پشتیبانی) با migration و API امن؛ سپس تکمیل تنظیمات اتصال پنل با ذخیره‌سازی امن و بدون نمایش دوباره secret.


### 2026-10-16: تنظیمات پایدار فروشگاه و API عمومی

- **فاز:** C — تکمیل تنظیمات قابل مدیریت فروشگاه.
- **کارهای انجام‌شده:** مدل singleton `StoreSettings` با نام فروشگاه، توضیحات، ارز پیش‌فرض، لینک پشتیبانی HTTPS و maintenance flag اضافه شد. migration جدید `0003_store_settings` جدول را می‌سازد و یک ردیف پیش‌فرض امن درج می‌کند. endpointهای محافظت‌شده `GET/PATCH /api/v1/admin/settings` و endpoint فقط‌خواندنی `GET /api/v1/store/settings` اضافه شدند؛ API عمومی فقط تنظیمات نمایشی را می‌دهد و هیچ credential پنل در آن نگهداری یا نمایش داده نمی‌شود. داشبورد ادمین فرم بارگذاری/ویرایش/ذخیره این تنظیمات دارد. ارز پیش‌فرض به‌عنوان مقدار پیشنهادی فرم ساخت پلن استفاده می‌شود. خطاهای ذخیره تنظیمات به پاسخ عمومی امن تبدیل می‌شوند و فیلدهای اجباری null را نمی‌پذیرند.
- **فایل‌های تغییرکرده:** `app/models.py`, `app/schemas.py`, `app/routes/admin.py`, `app/routes/store.py`, `app/static/admin.html`, `migrations/versions/0003_store_settings.py`, `tests/test_admin.py`, `README.md`, `todo.md`.
- **تست‌های واقعی:** `node --check` روی JavaScript inline موفق؛ `compileall` موفق؛ suite کامل در کانتینر موقت Python 3.12: **35 passed in 0.96s**. Migrationهای `0001` تا `0003` روی PostgreSQL 16 کاملاً موقت اجرا شدند؛ `alembic check` نتیجه `No new upgrade operations detected` داد و ردیف اولیه `1:ManubisGuard Store:IRR:false` تأیید شد. کانتینر دیتابیس موقت با trap پاک شد.
- **محدوده ایمنی:** هیچ migration روی production اجرا نشد؛ هیچ API call احراز هویت‌شده به پنل اصلی، deployment، restart سرویس یا push گیت انجام نشد.
- **محدودیت‌ها:** API و UI با مرورگر واقعی و دیتابیس/توکن production هنوز end-to-end تست نشده‌اند. maintenance flag فعلاً تنظیم قابل نمایش است و هنوز خرید/سفارش واقعی وجود ندارد که با آن قفل شود. تنظیم Base URL و credential پنل از داشبورد هنوز پیاده‌سازی نشده؛ این بخش باید با secret storage سمت سرور و بدون ارسال/نمایش کلید در مرورگر انجام شود.
- **قدم بعدی:** تست integration واقعی CRUD تنظیمات و پلن روی staging، سپس طراحی و پیاده‌سازی ذخیره امن پیکربندی اتصال پنل؛ بعد از آن هویت مشتری و API اشتراک/سفارش. قبل از هر deploy، مسیر و مالکیت repository مستقل `store-backend` مشخص شود.


### 2026-10-16: سخت‌سازی هدرهای داشبورد و پاسخ‌های مدیریتی

- **فاز:** C — سخت‌سازی امنیتی پنل مدیریت فروشگاه.
- **کارهای انجام‌شده:** middleware امنیتی در `store-backend/app/main.py` اضافه شد: `X-Content-Type-Options: nosniff`، `Referrer-Policy: no-referrer`، `X-Frame-Options: DENY` و `Permissions-Policy` محدودکننده. داشبورد `/admin` دارای `Cache-Control: no-store, max-age=0`، `Pragma: no-cache` و CSP با محدودیت منبع، frame و form شد. تمام مسیرهای `/api/v1/admin` نیز صریحاً از cache شدن پاسخ‌ها منع می‌شوند.
- **تست‌ها:** تست مستقل هدرهای داشبورد اضافه شد و تست pagination موجود برای عدم cache پاسخ admin API گسترش یافت. ابتدا یک تست قدیمی به‌خاطر تغییر مقدار دقیق Cache-Control شکست خورد؛ انتظار تست با سیاست جدید هماهنگ شد. سپس کل suite در کانتینر موقت Python 3.12: **36 passed in 0.93s**. `python3 -m compileall -q app migrations tests` موفق؛ اسکریپت inline از HTML استخراج و `node --check` موفق.
- **مستندات:** README با توضیح هدرها و محدودیت‌های آن‌ها به‌روزرسانی شد.
- **ایمنی/محدودیت:** فقط فایل‌های محلی backend و `todo.md` تغییر کردند؛ production، دیتابیس، پنل اصلی، سرویس‌ها و Android APK دست‌نخورده‌اند. این پوشه `store-backend` هنوز Git repository مستقل ندارد، بنابراین `git diff --check` در آن قابل اجرا نبود. هدرها جایگزین HTTPS، rate limiting، audit logging و محدودسازی دسترسی شبکه نیستند.
- **قدم بعدی:** پیاده‌سازی پیکربندی اتصال پنل از داشبورد با URL اعتبارسنجی‌شده، کلید رمز‌شده سمت سرور و بدون بازگرداندن secret؛ سپس اتصال واقعی adapter به تنظیمات جدید و تست‌های mock. کلید تازه و کم‌دسترسی و محیط staging برای تست زنده همچنان لازم است.


### 2026-10-16: تنظیم اتصال پنل از داشبورد با رمزنگاری سمت سرور

- **فاز:** C — اتصال قابل‌تغییر پنل و امن‌سازی credential.
- **کارهای انجام‌شده:** مدل `PanelConnectionSettings` و migration `0004_panel_connection_settings` اضافه شدند. تنظیمات مدیریت‌شده در PostgreSQL شامل Base URL و ciphertext کلید است؛ API key با Fernet و کلید مستقل `PANEL_SETTINGS_ENCRYPTION_KEY` پیش از ذخیره رمز می‌شود. APIهای محافظت‌شده `GET/PATCH /api/v1/admin/panel/connection` فقط URL، وضعیت تنظیم کلید و آمادگی رمزنگاری را برمی‌گردانند و هرگز خود کلید را نمایش نمی‌دهند. داشبورد امکان تغییر URL و ثبت/تعویض کلید را دارد؛ ورودی کلید پس از ارسال یا خطا پاک می‌شود و در مرورگر ذخیره نمی‌شود. `PanelClient` حالا از تنظیمات رمزگشایی‌شده دیتابیس استفاده می‌کند؛ endpointهای تست اتصال و دریافت قالب‌ها به این factory متصل شدند. وقتی رکورد مدیریت‌شده وجود ندارد، تنظیمات قدیمی environment به‌عنوان fallback باقی می‌مانند. `/health/ready` نیز وجود تنظیمات مدیریت‌شده و کلید رمزنگاری را لحاظ می‌کند.
- **اعتبارسنجی URL:** HTTPS اجباری؛ credentials/query/fragment ممنوع؛ فقط پورت 443؛ localhost، پسوندهای محلی/رزروشده و IPهای غیرعمومی رد می‌شوند. این کنترل، محافظت کامل در برابر DNS rebinding/SSRF نیست؛ admin API باید در شبکه/پروکسی مورداعتماد محدود بماند.
- **تست‌ها:** تست‌های URL، ردکردن path prefix، رمزگذاری/رمزگشایی، ردکردن نبود کلید رمزنگاری، ساخت PanelClient از رکورد رمز‌شده و عدم افشای کلید در پاسخ API اضافه شدند. URL پنل به origin بدون path محدود شد تا مسیرهای API با base URL اشتباه resolve نشوند. اجرای نهایی suite در کانتینر موقت Python 3.12: **53 passed in 0.95s**. `compileall` و `node --check` روی JavaScript داشبورد موفق. روی PostgreSQL 16 موقت، migrationهای `0001` تا `0004` اجرا شدند؛ `alembic check` خروجی `No new upgrade operations detected` داد؛ جدول پنل موجود و بدون رکورد اولیه تأیید شد. کانتینر و شبکه آزمایشی با cleanup حذف شدند.
- **مستندات:** README و `.env.example` برای کلید رمزنگاری، تولید Fernet key، backup امن کلید و ریسک از دست‌دادن آن به‌روزرسانی شدند.
- **ایمنی/محدودیت:** فقط فایل‌های محلی backend، تست‌ها، مستندات و `todo.md` تغییر کردند. هیچ migration روی دیتابیس production، تماس احراز هویت‌شده با پنل واقعی، restart/deploy، commit یا push انجام نشد. تست اتصال زنده هنوز نیازمند کلید تازه و کم‌دسترسی و staging مجاز است. قبل از استفاده از تنظیمات مدیریت‌شده باید migration `0004` روی دیتابیس مقصد با backup و برنامه rollback اجرا شود و `PANEL_SETTINGS_ENCRYPTION_KEY` پایدار و امن نگهداری شود.
- **قدم بعدی:** افزودن audit log امن برای تغییر تنظیمات حساس و rate limiting/کنترل دسترسی مدیریتی؛ سپس تست integration endpointها روی staging. بعد از تأیید اتصال واقعی، رفتن سراغ auth مشتری، اشتراک‌ها و چرخه سفارش، بدون فعال‌سازی پرداخت واقعی تا انتخاب provider و تکمیل webhook امن.


### 2026-10-16: آماده‌سازی backend برای push و دیپلوی آزمایشی ایزوله

- **فاز:** G — بسته‌بندی و تست staging، فقط برای کاتالوگ/داشبورد فعلی.
- **فایل‌های جدید:** `store-backend/Dockerfile`، `compose.yaml`، `.dockerignore`، `.env.compose.example`، `DEPLOY_TEST.md`، `scripts/smoke_test.sh` و `.github/workflows/test.yml`. `.gitignore` و `README.md` هم به‌روزرسانی شدند.
- **بسته‌بندی:** Docker image با Python 3.12 ساخته شد؛ اپ با کاربر غیر root اجرا می‌شود، فایل‌سیستم container read-only است، capabilityها حذف شده‌اند، `no-new-privileges` فعال است و API به‌صورت پیش‌فرض فقط روی `127.0.0.1:8091` منتشر می‌شود. PostgreSQL فقط روی شبکه داخلی Compose است. Health check کانتینر liveness را بررسی می‌کند تا در تست اولیه نبود credential پنل باعث restart loop نشود.
- **دیپلوی آزمایشی واقعی:** یک stack مستقل با نام `manubisguard-store-smoke`، دیتابیس موقت و secretهای تصادفی موقت بالا آمد. migrationهای `0001` تا `0004` با موفقیت اجرا شدند؛ `alembic check` نتیجه `No new upgrade operations detected` داد. Smoke test از روی سرویس در پورت loopback موقت `18091` این نتایج را داد: `/health/live` = 200، `/admin` = 200، `/api/v1/store/settings` = 200، `/api/v1/store/plans` = 200، درخواست بدون توکن به `/api/v1/admin/plans` = 401. سپس کانتینرها، شبکه، volume دیتابیس آزمایشی و فایل env موقت حذف شدند. هیچ سرویس یا دیتابیس production تغییر نکرد.
- **تست مجدد:** suite کامل در Python 3.12: **53 passed in 0.98s**؛ `compileall` موفق؛ `node --check` برای JavaScript داشبورد موفق؛ `docker compose config --quiet` موفق؛ Docker image build موفق؛ `git diff --check` برای تغییرات Android موفق. بررسی الگوهای رایج secret در سورس backend نتیجه‌ای پیدا نکرد و فایل `.env` واقعی در پوشه backend وجود ندارد.
- **CI:** workflow اضافه شد تا در push/PR، PostgreSQL 16، migration/schema check، pytest، compileall، JavaScript syntax، Compose validation و Docker build اجرا شوند. چون backend هنوز repository مستقل ندارد، این GitHub Actions workflow فعلاً روی GitHub اجرا نشده است.
- **آمادگی انتشار:** backend فعلی برای push به یک repository مستقل و staging loopback محدود آماده‌تر شده است، اما هنوز هیچ commit یا push انجام نشده چون remote مقصد backend مشخص نیست. کلاینت Android همچنان فقط 17 فایل تغییر برند محلی دارد و APK ساخته نشده است.
- **موانع قبل از beta عمومی/پرداخت:** حساب مشتری، اشتراک مالکیت‌دار، سفارش، درگاه پرداخت و webhook معتبر، idempotent fulfilment، provisioning بعد از پرداخت تأییدشده، audit log، rate limiting مدیریتی و ادغام فروشگاه در Android هنوز پیاده‌سازی نشده‌اند. admin API نباید در اینترنت عمومی منتشر شود؛ staging فعلی فقط برای کاتالوگ و داشبورد است. تست واقعی adapter با پنل به API key تازه، کم‌دسترسی و staging مجاز نیاز دارد.
- **قدم بعدی:** مقصد Git مستقل برای backend را مشخص کنیم و پس از بررسی نهایی diff، commit/push را جداگانه انجام دهیم. برای تست بعدی می‌توان همین Compose stack را با `.env` امن در محیط staging اجرا کرد؛ قبل از دسترسی از بیرون، TLS reverse proxy و allowlist/rate limit باید فراهم شود. برای تکمیل محصول واقعی، ادامه کار بعد از این مرحله باید روی auth مشتری، subscription adapter و lifecycle سفارش متمرکز باشد، نه فعال‌کردن پرداخت نمایشی.

## 2026-10-16 — Android test APK build
- Provisioned an isolated Android build toolchain under `/opt/android-sdk`, `/opt/Qt`, and `/opt/manubisguard-build`; production services and databases were not changed.
- Built the Android ARM64 (`arm64-v8a`) native client from the current working tree and packaged the OSS release variant with a dedicated test keystore.
- Fixed the generated Android compile SDK for the Qt 6.10.1 toolchain to API 36 while retaining min SDK 28. Excluded slow Android lint-vital tasks for this test artifact only; this is not a store-release certification.
- Set the Android application ID to `org.manubisguard.vpn`, updated the FileProvider authority and import-config action to the Manubis Guard namespace, while retaining the Java/Kotlin namespace `org.amnezia.vpn` required by the existing source packages.
- Output copied to `/root/ManubisGuard-test.apk`. APK signature verification and ZIP integrity checks passed; package label is `Manubis Guard`, package ID `org.manubisguard.vpn`, min SDK 28, target SDK 36, ARM64 only.
- Build artifact is signed with a temporary test certificate, not a production/release signing key. This build has not been installed on a physical phone or runtime-tested yet. The store UI is not integrated, and this APK is for controlled manual testing only.

## 2026-10-16 — Manubis Guard UI implementation + staging catalogue endpoint

- Status: corrected the earlier gap; the previous APK had branding only. This stage adds real initial UI screens.
- Screens: PageManubisDashboard.qml for the dark/blue dashboard, connection state and CTA; PageManubisStore.qml for live catalogue, price/duration/quota and refresh; PageManubisAccount.qml for initial login layout and guest mode. PageStart.qml now has five destinations: dashboard/store/VPN/account/settings. New routes were added to pageEnum.h and qml.qrc. TabBarButtonType.qml shows labels under icons.
- Store API: base URL is https://all.qoqnusradio.top/store-api; the Store page fetches the catalogue on open. An isolated Compose stack manubisguard-store-test with its own PostgreSQL and random secrets in .env (mode 0600) is running; migrations 0001–0004 were applied. API binding is loopback-only at 127.0.0.1:8091.
- Security boundary: only GET /store-api/api/v1/store/plans is exposed through Nginx. All other /store-api/ routes return 404 publicly, including admin routes. Unauthenticated admin API request on loopback returns 401. Panel API key is not configured and no authenticated call was made to the panel. Public catalogue currently returns [] because no real plan has been registered in staging.
- Build: CMake target AmneziaVPN succeeded; qmllint on new screens exited 0. Gradle assembleOssRelease succeeded. APK uses the same test certificate as the previous build so it can update the installed package. apksigner verification and unzip integrity test passed. Package org.manubisguard.vpn, label Manubis Guard, min SDK 28, target SDK 36, ARM64.
- Artifact: /root/ManubisGuard-test.apk and /var/www/manubisguard-downloads/ManubisGuard-test.apk; URL https://all.qoqnusradio.top/downloads/ManubisGuard-test.apk. SHA-256 c8d4b7353c30ffecc018981779d69a77f2c8531493ec4074163f48d8443b780b. External range-download returned 206 with correct MIME and 128 bytes. Public catalogue endpoint returned 200 []; public admin route returned 404.
- Limitations: no physical Android device is attached to the build server over ADB, so launch/crash and visual runtime could not be observed remotely. The app-closing issue still needs runtime reproduction or crash log. Login is UI only; customer auth does not exist yet. Selecting a plan explains that real payment is disabled; order/payment/webhook/automatic activation are not implemented. Real plans must be added to the staging catalogue; doing so against the panel requires a new least-privilege panel API key.
- Safety: only the new staging services, exact Nginx catalogue paths, and test APK changed; no production database or main panel was migrated/restarted. Keys remain in the local .env and were not sent to the client or public web. No commit or push was performed.
- Next: install the new APK on the phone and check dashboard/navigation/crashes; then add a real plan to staging with approved panel credentials. Complete customer auth and order/payment/activation before claiming real purchases work.

# برنامه رفع باگ و بازطراحی اختصاصی — اولویت اجرایی 2026-10-16

## قانون اجرا
هیچ قابلیت فروش/اشتراک جدیدی تا عبور از فاز 1 وارد APK نمی‌شود. هر فاز باید با تست و گزارش ثبت شود؛ باگ‌های بعدی که کاربر معرفی می‌کند به backlog اضافه می‌شوند و ترتیب اولویت با تأیید همین فهرست جلو می‌رود. هسته اتصال VPN فعلاً حفظ می‌شود، اما صفحه‌ها و جریان‌های قابل مشاهده باید اختصاصی Manubis Guard شوند.

## فاز 1 — رفع کرش هنگام شروع (BLOCKER / IN PROGRESS)
- [ ] بازتولید کرش روی گوشی واقعی یا emulator و ثبت logcat از اولین launch تا خروج process.
- [x] بررسی اولیه مسیر شروع در `main2.qml` و `PageStart.qml` و بررسی ثبت QML resourceها و `PageController::getPagePath()`؛ مسیر صفحه با نام enum ساخته می‌شود و فایل‌های جدید در `qml.qrc` ثبت شده‌اند.
- [x] بررسی اولیه ابزار build: ADB هیچ دستگاهی متصل نمی‌بیند؛ emulator و system image نصب‌شده‌ای در سرور وجود ندارد؛ بنابراین runtime crash هنوز از سرور قابل بازتولید نیست.
- [x] اجرای `qmllint` روی `PageStart.qml` و سه صفحه Manubis؛ exit code برابر 0 است، اما این تست جایگزین تست زمان اجرا نیست و هشدارهای import به علت نبود مسیر ماژول‌های build در اجرای lint به‌تنهایی اثبات کرش یا سلامت runtime نیستند.
- [ ] گرفتن crash trace واقعی (FATAL EXCEPTION / AndroidRuntime، `libc` signal یا Qt/QML fatal) طبقه‌بندی علت پیش از هر تغییر حدسی در lifecycle/native code.
- [ ] رفع علت مشخص‌شده، build مجدد و تست cold launch حداقل 10 بار متوالی، resume از background و بازکردن Store/VPN؛ ثبت نتیجه و SHA APK.
- **شرط عبور:** هیچ خروج ناخواسته در تست تکراری و دلیل کرش مستند شده باشد. تا آن زمان این باگ «حل‌شده» اعلام نمی‌شود.

## فاز 2 — حذف UI قدیمی از جریان‌های کاربر (پس از فاز 1)
- [ ] نقشه تمام مسیرهای قابل‌دسترسی از داشبورد، اشتراک، خرید، تمدید، حساب، VPN و تنظیمات تهیه شود؛ مشخص شود کدام صفحه‌های upstream هنوز در مسیر کاربر دیده می‌شوند.
- [ ] ساخت navigation اختصاصی Manubis Guard؛ هیچ کلیک روی «اشتراک»، «خرید»، «تمدید» یا «حساب» نباید صفحه قدیمی upstream را نشان دهد.
- [ ] پیاده‌سازی صفحه اختصاصی مدیریت VPN با استفاده از controller/engine موجود؛ نگه‌داشتن هسته اتصال به معنی نگه‌داشتن UI قدیمی نیست.
- [ ] جایگزینی wizard واردکردن اشتراک با flow اختصاصی Manubis Guard؛ اگر لازم است از parser/controller داخلی استفاده شود، فقط لایه UI داخلی پنهان بماند.
- [ ] حذف یا مخفی‌کردن مسیرهای قدیمی از navigation؛ حذف فایل‌های upstream فقط پس از بررسی وابستگی‌ها، تا قابلیت اتصال نشکند.
- [ ] بازبینی کامل برندینگ قابل‌مشاهده: عنوان‌ها، dialogها، onboarding، خطاها، notificationها، import flow و صفحه About.
- **شرط عبور:** مسیرهای اصلی کاربر با UI اختصاصی پوشش داده شوند و هیچ صفحه upstream از flowهای اصلی قابل‌دسترسی نباشد.

## فاز 3 — UI کاملاً جدید مبتنی بر قرارداد backend
- [ ] تعریف API contract نهایی برای تنظیمات عمومی فروشگاه، کاتالوگ، حساب مشتری، اشتراک‌های متعلق به کاربر، سفارش‌ها و وضعیت پرداخت.
- [ ] ساخت مدل/لایه شبکه در کلاینت (timeout، خطای قابل‌فهم، retry محدود، حالت offline و schema validation) به‌جای پراکندگی درخواست‌های مستقیم داخل QML.
- [ ] طراحی و ساخت داشبورد، فروشگاه، جزئیات پلن، خرید/تمدید، حساب، اشتراک‌های من و مدیریت اتصال مطابق API واقعی.
- [ ] نمایش empty/loading/error states واقعی؛ کاتالوگ خالی نباید به‌جای داده واقعی محصول ساختگی نشان دهد.
- [ ] تست قرارداد کلاینت/سرور و navigation در اندازه‌های مختلف صفحه و زبان فارسی/RTL.
- **شرط عبور:** UI از داده واقعی backend استفاده کند و هیچ دکمه‌ای وانمود نکند که login، خرید یا فعال‌سازی انجام شده است مگر backend واقعاً آن را تأیید کرده باشد.

## فاز 4 — حساب، سفارش و فعال‌سازی end-to-end
- [ ] احراز هویت مشتری و مالکیت اشتراک‌ها.
- [ ] چرخه سفارش و اتصال امن به پنل اصلی با کمترین دسترسی لازم.
- [ ] درگاه پرداخت و webhook امضاشده/idempotent فقط پس از انتخاب provider؛ فعال‌سازی فقط پس از تأیید معتبر پرداخت.
- [ ] تست خرید/تمدید در sandbox و تأیید وضعیت واقعی اشتراک در پنل.

## فاز 5 — QA، بسته‌بندی و انتشار آزمایشی
- [ ] تست cold start/relaunch/resume، Android 13–16، import لینک، اتصال/قطع، خطای شبکه، API خالی/خراب و upgrade APK.
- [ ] حذف branding باقی‌مانده upstream از تمام سطوح قابل‌مشاهده، بررسی permissionها و signing/release setup.
- [ ] تولید APK فقط بعد از عبور فازهای قبلی، انتشار changelog و ثبت SHA-256.

## یافته‌های شروع بررسی در 2026-10-16
- APK قبلی runtime روی گوشی کاربر آزمایش نشده بود و سرور هیچ ADB device/emulator ندارد؛ بنابراین علت کرش هنوز با شواهد runtime مشخص نشده است.
- `PageStart.qml` در نسخه فعلی مستقیماً `PageManubisDashboard` را به StackView اضافه می‌کند. مسیر صفحه از `PageController::getPagePath()` بر پایه نام enum ساخته می‌شود؛ سه QML جدید در `qml.qrc` ثبت شده‌اند. این بخش نیاز به trace زمان اجرا دارد، نه فرض‌گرفتن علت.
- UI قبلی هنوز عملاً قابل‌دسترسی است: تب VPN به `PageHome` قدیمی می‌رود، صفحه حساب به `PageSetupWizardConfigSource` قدیمی می‌رود، و Settings همچنان از صفحات قدیمی استفاده می‌کند. این در فاز 2 باید بازطراحی شود؛ پیش از فاز 1 نباید چند تغییر UI هم‌زمان، تشخیص کرش را مبهم کند.
- آخرین `qmllint` روی فایل‌های هدف exit 0 داد؛ با این حال warningهای زیادی از import path و unqualified access وجود دارد و runtime/QML warnings هنوز روی دستگاه بررسی نشده‌اند.
- **نیاز تست فاز 1:** لاگ واقعی از گوشی هنگام بازشدن و بسته‌شدن برنامه. تا اتصال دستگاه یا دریافت trace، تغییر حدسی در native lifecycle به‌عنوان «رفع کرش» پذیرفته نمی‌شود.

### 2026-10-16 — ادامه دیباگ فاز 1 (static audit)
- دوباره وضعیت سرور را بررسی کردم: ADB هنوز هیچ دستگاهی ندارد. نصب و اجرای Android Emulator روی همین سرور را فعلاً انجام ندادم، چون میزبان فقط حدود 3.7 GiB RAM دارد و swap تقریباً پر است؛ اضافه‌کردن emulator + ARM64 system image و اجرای آن می‌تواند روی سرویس‌های همین میزبان فشار غیرضروری ایجاد کند.
- بررسی APK: `aapt dump badging` تأیید کرد package=`org.manubisguard.vpn`، min SDK=28، target/compile SDK=36، Activity اصلی `org.amnezia.vpn.AmneziaActivity` و label=`Manubis Guard` است. کتابخانه native شامل نام هر سه صفحه Manubis است؛ مسیر resourceهای QML در `qml.qrc` ثبت شده. این‌ها صحت بسته‌بندی/وجود resource را نشان می‌دهد، نه اینکه صفحه بدون crash اجرا شده باشد.
- بررسی manifest/Kotlin diff: تغییرهای branding در Activity عمدتاً نام نمایشی، action مربوط به import و FileProvider authority هستند؛ namespace کلاس‌های Kotlin عمداً `org.amnezia.vpn` باقی مانده چون کلاس‌ها در همان package قرار دارند. از این بررسی به‌تنهایی علت crash به دست نیامد.
- کاتالوگ staging از سرور با HTTPS پاسخ HTTP 200 و `[]` می‌دهد؛ صفحه داشبورد اولیه خودش درخواست کاتالوگ نمی‌زند، پس پاسخ خالی API توضیحی برای crash در launch نیست.
- اسکریپت تشخیصی `tools/capture-android-crash.sh` اضافه شد. اگر دستگاه Android به ADB همان میزبان وصل و authorize شود، logcat را بدون پاک‌کردن buffer قبلی ثبت می‌کند، یک بار برنامه را launch می‌کند و markerهای crash را استخراج می‌کند. در حال حاضر اجرا نمی‌شود چون دستگاه متصل نیست.
- نتیجه: هنوز علت crash واقعی اثبات نشده و هیچ patch حدسی برای lifecycle/native startup اعمال نشد. برای ادامه فاز 1 نیاز به logcat/bug report از گوشی کاربر یا اتصال مجاز ADB داریم. بعد از مشخص‌شدن علت، اصلاح و build/test انجام می‌شود؛ فاز UI اصلی هنوز به APK جدید نرفته است.
- Build attempt note (2026-10-16): Qt's `androiddeployqt` generated a Gradle build configured with `-Xmx4g` and parallel tasks. On this 3.7 GiB host, the JVM was OOM-killed during APK packaging. I stopped only the affected build processes; the VPN/store services stayed running. I lowered the project's Gradle heap to 1280 MiB, metaspace to 512 MiB, disabled parallel Gradle tasks, and limited workers to 1 before retrying, to avoid repeating memory pressure.

### 2026-10-16 — Static QML fix + signed test APK rebuild
- [x] Static audit found `PageManubisAccount.qml` referenced `PageEnum.PageSetupWizardConfigSource` without importing `PageEnum 1.0`; added the explicit import so the account page's import-subscription action resolves its enum.
- [x] Removed unused imports from the new dashboard/store pages; adjusted the dashboard status dot to use `Layout.preferredWidth/Height` instead of fixed width/height inside `RowLayout`.
- [x] Added `pragma ComponentBehavior: Bound` to the store page so delegate references to outer page properties have defined Qt 6 behavior.
- [x] `qmllint` exits 0 on the three Manubis pages. It still reports warnings (including generated C++ modules `PageEnum`/`Style` not discoverable by standalone lint import paths and unqualified access); there are no syntax errors. These warnings are not runtime crash proof.
- [x] Rebuilt native Android library and QML resource bundle; built the `ossRelease` APK successfully with the test signing certificate. The first all-flavors `androiddeployqt` invocation hit the host's 4 GiB Gradle heap and was OOM-killed; it was stopped, Gradle memory/worker settings were reduced, and the targeted signed `assembleOssRelease` succeeded. No application/service container was stopped.
- [x] APK checks passed: `unzip -t`, `apksigner verify`, package metadata (`org.manubisguard.vpn`, label `Manubis Guard`, min SDK 28 / target SDK 36), and presence of all three Manubis page names in the embedded native resource.
- [x] Updated test APK at `/root/ManubisGuard-test.apk` and public staging download `/var/www/manubisguard-downloads/ManubisGuard-test.apk`. HTTP range request to the download URL returned 206 with APK MIME and total size 76,975,320 bytes.
- **Test APK SHA-256:** `8fbd4b0a92786c798999bdb3551f0c2dd7ae6e2d6513d88224d319292d285348`.
- **Important:** this is a static-fix test build, not a confirmed crash fix. The server still has no ADB device/emulator, so Android launch/crash remains unverified. Need a real device logcat/bug report to establish the launch failure cause. Do not mark phase 1 complete until repeated cold-launch/resume tests pass.

### 2026-10-16 — Crash report received + Android renderer diagnostic build
- [x] Reviewed the user's Redmi `tanzanite_global`, Android 16 / HyperOS 3 native tombstone. Stack is `abort` -> `QMessageLogger::fatal` -> `libplugins_platforms_qtforandroid` -> `QOpenGLContext::makeCurrent` -> `QRhi::beginFrame` -> Qt Quick render thread. This strongly points to Qt Android OpenGL context/surface handling or the device GPU driver path, not to the store catalogue request. The supplied excerpt has no fatal message string or preceding logcat, so the exact triggering condition is not yet proven.
- [x] Added an Android-only diagnostic workaround in `client/main.cpp`: select `QSGRendererInterface::Software` via `QQuickWindow::setGraphicsApi(...)` before constructing the application/window, and emit a startup log marker. This avoids the OpenGL renderer path for the test APK; performance/effect compatibility and crash elimination must be confirmed on the actual Redmi.
- [x] Rebuilt native ARM64 library/QML bundle and `ossRelease` APK; Gradle finished `BUILD SUCCESSFUL` using low-memory single-worker settings. No production service was stopped or restarted.
- [x] Verified APK zip integrity, v2 signature, package `org.manubisguard.vpn`, label `Manubis Guard`, min SDK 28/target SDK 36, and the software-renderer marker in the embedded native library.
- [x] Updated existing public test URL in place: `https://all.qoqnusradio.top/downloads/ManubisGuard-test.apk`; HTTP Range check returned 206 with APK MIME. New size: 76,975,396 bytes. SHA-256: `9d7cb34641b40ebd34de5e98ee0e06d59d9b1c18c340b5887c6c3f6eefe341a6`.
- [ ] Install/update this diagnostic build on the user's Redmi and verify at least 10 cold launches, background/resume, and whether any Qt Quick visual/rendering regressions appear. If it still crashes, collect full logcat lines before the tombstone and reconsider the Android surface lifecycle/context path.
- **User UI requirements captured (2026-10-16):** the intended home page is a VPN connect/disconnect screen, not a dashboard. Every customer is entitled to a monthly free traffic allowance, and the UI must show actual remaining/used quota from a real backend source, never invented placeholder numbers. The add-subscription action must open a Manubis-specific import flow, not `PageSetupWizardConfigSource`. All old upstream pages must be removed from user-facing navigation, while retaining VPN engine/controllers. User will send screenshots of reference apps; wait for these before final visual styling. Current diagnostic APK intentionally does not claim these UI redesign requirements are complete.

## Product reset: complete UI replacement specification (2026-10-16)

### Non-negotiable product intent
- Treat the existing upstream Amnezia UI as legacy, not as a starting point to keep decorating. The user-facing UI is considered **not designed yet** and must be rebuilt from a clean product/UI layer.
- Preserve and reuse the underlying VPN capabilities/engines and integration needed for Xray/eXray and Amnezia/WireGuard. Do not rewrite these protocol engines from scratch. Keep necessary VPN service, connection controller, profile/config handling, and platform permissions/lifecycle plumbing where sound.
- Before removing/replacing legacy UI routes, create a source backup or a clearly named Git branch/tag/commit and record its exact location/revision. Do not destructively delete engine/controller code. Old UI must not be reachable through any user-facing navigation after migration.
- Product reference: JumpJump VPN's visual simplicity and one-tap connection flow, not a pixel-for-pixel copy. Reference screenshots researched: simple main connect toggle/status, a separate location picker, settings grouped into clear rows, and compact routing-mode choices. Build an original Manubis Guard visual identity.

### Target user experience
1. **First launch / language onboarding**: show a clean language-selection screen before the main app. Initial supported languages: Persian (fa, RTL), English (en, LTR), Russian (ru, LTR). Persist choice; allow changing it later in Settings. No old upstream onboarding screens.
2. **VPN Home**: a minimal, polished screen whose primary action is one large Connect/Disconnect button and a clear state (disconnected, connecting, connected, disconnecting, error). Show selected location and connection information without clutter. Do not make a dashboard the home screen.
3. **Collapsed location selector**: show the currently selected location in a compact panel/card near the bottom. Tapping it opens a dedicated picker/bottom sheet. Populate it dynamically from the actual active locations returned by the configured panel/API; do not hardcode countries or display fictional/offline locations. Include loading, empty, error, latency/availability states only when data is real, and sensible sorting/favorites if supported.
4. **Navigation**: a simple menu/drawer or compact navigation affordance, inspired by familiar consumer apps, provides Home, Dashboard/Usage, Store/Subscriptions, Import Subscription, VPN Settings, Account, Help/About. Keep navigation shallow and consistent; every visible button must have a working destination or be clearly disabled with a reason. Never route to old Amnezia pages.
5. **Dashboard / usage**: separate from Home. Show account/subscription state, monthly free allowance granted by admin, usage to date, remaining allowance, reset date/period, and purchased plan/expiry where available. Values must come from the backend/API, not hardcoded demo numbers. Handle missing/unavailable quota data honestly.
6. **Store**: first-class Manubis Guard storefront for real products/plans returned by the configured backend. Include plan details, purchase/renewal entry points, current subscription state, empty/loading/error states, and clear authentication/payment status. Do not invent products, prices, successful purchases, or transactions. No mock checkout presented as real.
7. **Import Subscription**: custom Manubis Guard flow to paste/import a subscription URL or add an account/subscription using supported backend flow. Validate input, show progress/errors, and hand off to the retained VPN configuration/controller layer. It must not open `PageSetupWizardConfigSource` or any old upstream wizard.
8. **VPN Settings**: redesigned, simple settings for supported routing modes (e.g. Smart/Global only if the engine actually supports them), split tunneling only if supported, protocol/connection options, diagnostics, and restore defaults. Explain advanced choices in plain language. Do not show controls that are not wired to real behavior.
9. **Account**: custom login/register/logout/profile/subscription screens using the agreed backend API. Guest mode may be offered only if compatible with backend policy. No upstream account screens.
10. **Admin configuration**: admin-managed controls for monthly free quota per user (and, if required, policy by account/plan), store content/plans, availability/visibility of locations, and panel/API endpoint configuration. The app must read these settings from authenticated backend endpoints. Keep privileged admin functions server-authorized; do not embed admin secrets in the APK. If the admin interface is a separate web dashboard, define and document that boundary/API.

### Architecture and integration requirements
- Separate the new UI/presentation layer from VPN engine/service/controller and from store/account backend clients. Prefer clear interfaces/adapters so panel/API base URL can be changed centrally without editing every screen.
- Inspect current app architecture and all navigation entry points before changes. Identify retained engine/controller classes and legacy UI files; document what is safe to replace and what must remain.
- Build a route inventory and prove that no user-facing path reaches legacy `PageHome`, `PageSetupWizardConfigSource`, old setup wizard, old account pages, or old settings pages after cutover.
- Use backend contracts for dynamic locations, account, quota/usage, plans, subscription import, and admin configuration. The currently observed `/store-api/api/v1/store/plans` response is HTTP 200 with `[]`; treat the catalogue as empty until real plans are configured. Do not infer a quota endpoint or fake usage values; inspect/document the API and implement missing backend endpoints deliberately.
- Preserve Persian RTL layout, accessible text sizes, responsive Android layouts, keyboard/input behavior, loading/error/empty states, and localization of all visible strings. Avoid text baked into images.
- The Android 16 Redmi crash remains a separate release gate. The software-renderer diagnostic build has not yet been verified on the user's physical device; do not label it fixed without runtime evidence.

### Phased delivery plan and acceptance gates
- **Phase 0 — Baseline and safety backup**: inspect branch/status/build system/routes/controllers/APIs; record current commit and clean backup/branch; read this todo; capture build output and known crash baseline. No destructive UI changes until backup is confirmed.
- **Phase 1 — Stabilize startup and retain core**: investigate crash using full logcat/fatal message; test renderer workaround on real device if available; validate cold launch/resume/permissions/VPN connect-disconnect. Separate renderer diagnostics from UI redesign. Gate: app launches repeatedly without crash and engine/controller responsibilities are mapped. If physical-device testing is unavailable, mark runtime verification pending.
- **Phase 2 — UI/architecture inventory and design system**: map every legacy route and backend call; define new navigation, typography, spacing, color/tokens, reusable cards/buttons/sheets, and localization framework for fa/en/ru. JumpJump is an inspiration for simplicity only. Gate: route map + component plan + API contract recorded.
- **Phase 3 — Language onboarding and new app shell**: implement first-launch language picker, persistence, RTL/LTR, new navigation shell, and a new default Home. Route all tabs/menu items into new placeholders/screens; remove legacy routes from reachable navigation. Gate: no old UI is reachable and language switch works.
- **Phase 4 — VPN Home and location picker**: implement real connect/disconnect state against retained VPN controller; selected location card and dynamic picker sourced from active panel/API locations; real error/loading/offline states. Gate: verified connect/disconnect and location switching on device with actual configs; no fake location inventory.
- **Phase 5 — Account, subscription import, dashboard/quota**: custom auth flows; custom paste/import subscription flow; usage dashboard wired to real usage/quota endpoints. Define and implement missing API contracts if necessary. Gate: real backend data displayed, no old setup wizard reachable, malformed/expired subscription errors handled.
- **Phase 6 — Store and renewal**: wire catalogue, plan detail, purchase/renewal status to real backend/payment flow. Catalogue is currently empty, so test empty state until admin configures real plans. Gate: no fake checkout; transaction outcomes verified end-to-end before showing success.
- **Phase 7 — VPN settings and admin configuration**: implement only engine-supported routing options; create/administer quota, plans/store content, location visibility, and central panel/API configuration through secured backend/admin UI. Gate: server-side authorization, persistence, and end-to-end tests.
- **Phase 8 — QA, polish, release**: test Persian RTL, English/Russian LTR, small screens, Android 16/Redmi if available, cold start/restart/resume, VPN permission denial, network loss, API outage, empty store, expired/invalid subscriptions, quota reset boundaries, and no legacy route leaks. Run static checks/build/signature checks and publish a build report with SHA-256. Do not call release-ready until device/runtime gates pass.

### Working rules
- Implement and test in small phases, update this `todo.md` with timestamped changes, files touched, commands/results, blockers, and verification evidence after every phase.
- No claims of completion based only on compilation. Distinguish source/build validation from actual on-device verification.
- No invented API endpoints or fake values; inspect backend and define contracts where missing.
- Do not add a store as a thin layer over the old UI. The intended outcome is a complete, original Manubis Guard UI over the retained VPN core.


## 2026-10-16 17:56 UTC — Build-host stabilization / resource-pressure incident
- **Incident:** During Android packaging, CLY914129's Remote Desktop Commander became intermittently unresponsive. Follow-up checks showed 3.7 GiB RAM, swap fully occupied (~1.0 GiB), elevated load averages (initially 60.02 / 147.33 / 96.44), and an orphaned Kotlin compiler daemon (PID 1733370, parent PID 1) still using about 20% CPU and 513 MiB RSS after the CMake/Gradle packaging processes had exited.
- **Action:** Confirmed the known build/packaging process PIDs were no longer running, then terminated only the orphaned Kotlin compiler daemon. Did not restart the server, stop production containers/services, or forcibly reset swap.
- **After action:** Available RAM increased from ~1.3 GiB to ~1.8 GiB; the Kotlin/Gradle/androiddeployqt build process check returned empty. Swap remained full (~1.0 GiB), so keep monitoring rather than risk a disruptive swapoff on a production host. Load average fell to 28.46 / 126.76 / 91.88; these averages include historical pressure and need time to decay.
- **Artifact validation:** Candidate APK at /opt/manubisguard-build/android-arm64/client/android-build/build/outputs/apk/oss/release/android-build-oss-release.apk is 76,986,280 bytes. apksigner verify --verbose passed (APK Signature Scheme v2, one signer); unzip -t passed. SHA-256: f12cea4609328d9a786bcad52c39b535d7a5e3eac9bd0745cdf77c90c14b0e74.
- **Limitations:** No physical Android device/runtime verification was performed. Do not publish this APK as a verified runtime build yet. No commit/push has been made in this incident response.
- **Next gate:** Recheck host load, memory/swap, and top CPU processes before resuming development/build. Keep Android builds serial (--parallel 1) and ensure Gradle/Kotlin daemons are not left consuming resources after a failed/interrupted build.


## 2026-10-16 18:00 UTC — Swap expanded and cleared on CLY914129
- **Request:** Increase swap to 8 GiB and clear it once.
- **Before:** `/swapfile` was 1 GiB and fully used; root filesystem had about 8.9 GiB free. The existing `/etc/fstab` entry already used `/swapfile`.
- **Action:** Ran `swapoff /swapfile` successfully (migrating swapped pages back to RAM), removed the old file, created a new 8 GiB swap file with `fallocate`, set permissions to `0600`, initialized it with `mkswap`, and enabled it with `swapon`. No production containers or services were restarted.
- **Verified:** `swapon --show` reports `/swapfile` size 8G and used 0B; `free -h` reports 8.0 GiB swap with 0B used. Existing `/etc/fstab` entry `/swapfile swap swap defaults 0 0` remains in place for persistence across reboot.
- **Important trade-off:** Root filesystem now has only about 1.9 GiB free (97% used) because the new 8 GiB swap file occupies disk space. Avoid another large build/download until disk space is reviewed or freed safely. Available RAM at the immediate post-change check was about 866 MiB; recheck resource pressure before resuming the Android build.

- **Follow-up cleanup (read-only inspection then safe cleanup):** Found `/var/cache/apt/archives` held 566 MiB of downloadable package archives. Ran `apt-get clean` (does not uninstall installed packages); cache dropped to 44 KiB and free root disk increased from 1.9 GiB to 2.6 GiB. `/root/.gradle/caches` and `/opt/manubisguard-build` each occupy about 2 GiB and were left untouched to avoid breaking the Android build environment. Current disk is still 95% used, so avoid large downloads and inspect build artifacts before the next full build.


## 2026-10-16 18:06 UTC — UI shell checkpoint, route hardening, and rebuild
- **Source validation:** `git diff --check` passed. Ran `qmllint` against the new Manubis pages and `PageStart.qml`; no syntax/fatal/error diagnostics were found. The linter still emits expected standalone-analysis warnings for C++-registered QML singletons/enums such as `PageController`, `ConnectionController`, and `PageEnum`; these warnings are not equivalent to runtime validation.
- **Routing changes:** `PageStart.qml` maps old Home/setup/settings/protocol/service/about/dev routes to Manubis pages. Legacy share connection navigation no longer pushes `PageShareConnection`; it displays an explicit not-yet-available message. Share pages route to the custom account page. This is a first-pass central route guard, not yet a proof that every possible native/Qt signal path is covered.
- **Truthfulness fix:** Dashboard connection badge and status now reflect `ConnectionController` state, including an in-progress state; the subscription tile explicitly states its data is not connected to an API rather than implying that connection status supplies subscription details.
- **Backend inspection:** Live `GET https://all.qoqnusradio.top/store-api/api/v1/store/plans` returned HTTP 200 with `[]`; UI correctly shows an empty catalogue. Backend source confirms public plans/settings and protected admin plan/store/panel configuration routes exist, but customer authentication, quota/usage, order/payment, and subscription fulfilment endpoints are not yet implemented. Do not fake those data or transactions. Backend tests could not be run from this host because system Python has no pytest installed and no project test venv was found; GitHub Actions test workflow is defined in the backend repository.
- **Build:** Re-ran `cmake --build /opt/manubisguard-build/android-arm64 --config Release --parallel 1`; result `BUILD SUCCESSFUL` (331 actionable tasks, 188 executed, 55 cached, 88 up-to-date). Build produced the OSS APK. Android Gradle Plugin emitted its existing warning that AGP 8.6.1 was tested through compileSdk 35 while this project uses compileSdk 36; several upstream Android status/navigation bar deprecation warnings also appeared.
- **APK validation:** `/opt/manubisguard-build/android-arm64/client/android-build/build/outputs/apk/oss/release/android-build-oss-release.apk`, 76,986,448 bytes. `apksigner verify --verbose` passed with one signer and APK Signature Scheme v2; `aapt dump badging` reports package `org.manubisguard.vpn`, label `Manubis Guard`, target SDK 36; `unzip -t` passed. SHA-256: `8f1c8a0dba0714648da687543b02d9afdb6be2ecd80bb7f0d3273366953e4120`.
- **Build-host resource recovery:** Build temporarily filled disk to 98% and used about 2.2 GiB swap during Gradle packaging. After successful build, removed only regenerable `*playRelease*` intermediate directories (kept the OSS intermediates and both packaged APK outputs); disk free returned to about 2.3 GiB (96%), RAM available about 2.4 GiB. Swap remains 8 GiB, about 1.9 GiB used. Avoid parallel/full builds and monitor disk before future builds.
- **Not verified:** No physical Android device is connected/available for runtime checks. The APK has not been installed/launched on the Redmi Android 16 device; the Qt software-renderer workaround is not confirmed to fix the reported crash. Do not copy this APK to the public download URL or call it release-ready until runtime validation is performed.
- **Git:** Work remains on `feature/manubis-ui-rebuild`; source changes are still uncommitted/unpushed at this checkpoint. Next work: finish localization/RTL, prove legacy route closure, implement real account/subscription/quota API contracts and screens, and then checkpoint/push a clean phase.


## 2026-10-16 18:10 UTC — Checkpoint commit and Persian RTL pass
- Created local checkpoint commit `edbc2e63` (`feat(android): introduce Manubis Guard UI shell`) on `feature/manubis-ui-rebuild`, using an explicitly named local build-agent identity (no existing user identity was configured). Working tree was clean immediately after the commit.
- Push attempt to `origin` stalled at the HTTPS credential prompt (remote helper waited for terminal input; no GitHub credential was available in this shell). The attempted push was terminated; the local commit is preserved but is **not confirmed pushed**. Do not claim the branch is on GitHub. Retry only after authorized GitHub authentication is configured.
- After the checkpoint, added RTL mirroring to the 7 custom content pages (Home, Dashboard, Store, Account, Settings, Import Subscription, Import Review) based on `LanguageUiController.currentLanguageIndex === 4` (Persian enum index). `git diff --check` and QML error/syntax scan pass. These RTL edits are currently uncommitted and require a follow-up checkpoint after more UI work.
- Localization remains incomplete: the custom screens still contain a mixture of English and Persian strings. RTL mirroring alone does not satisfy full fa/en/ru localization. Next UI pass should centralize translated strings and verify direction changes on actual Android runtime.


## 2026-10-16 18:12 UTC — RTL checkpoint
- Committed Persian RTL mirroring as local commit `8ae55675` (`feat(android): mirror custom screens for Persian RTL`). Branch now has local commits `edbc2e63` and `8ae55675`; working tree is clean.
- This second commit was made **after** the successful APK build and is not included in the verified APK hash recorded above. QML static scan reports no syntax/fatal errors for these seven modified pages, but a rebuild is required before this commit can be represented in an APK.
- GitHub push remains blocked because HTTPS Git is waiting for credentials; no branch update on GitHub has been confirmed. Do not retry with guessed credentials. User-authorized GitHub authentication or an available authenticated GitHub connector workflow is needed.
- Translation catalog inventory found existing Persian (`amneziavpn_fa_IR.ts`) and Russian (`amneziavpn_ru_RU.ts`) catalogs. Full localization is still outstanding; most new screens still have a mixture of hardcoded Persian and English. The next pass should use these catalogs or a centralized Manubis string table and translate every visible label/status/error, then test language changes and RTL/LTR at runtime.


## 2026-10-16 21:58 +0330 — Store API integration pass
- Re-read the language enum/controller, startup routing, custom Store screen, and backend public store schemas/routes. Verified language enum indices are English=0, Russian=1, Persian=4; the current RTL predicate using index 4 matches the C++ controller.
- Updated `PageManubisStore.qml` to request both public endpoints: `/api/v1/store/plans` and `/api/v1/store/settings` over HTTPS. Store title and description now use the public settings response; an HTTPS support URL is exposed as a support button only when the API returns one.
- Added maintenance-mode UI handling: show a maintenance message, hide plan cards, and disable selection when `maintenance_mode=true`. Request completion order is handled so a successful plans response does not overwrite the maintenance status.
- Added display conversion for `price_minor` using currency minor-unit precision (zero-, two-, or three-decimal currency codes) and the selected locale. This is display formatting only; no checkout/payment/activation is claimed.
- Fixed support button content label binding (`supportButton.text`) after `qmllint` flagged an invalid `parent.text` lookup.
- Validation: `git diff --check` passes. Ran `qmllint` across all 8 custom pages plus `PageStart.qml`; no syntax/fatal/compile errors and no new missing-property diagnostics in `PageManubisStore.qml`. There are numerous existing QML warnings (mostly unqualified accesses and C++-registered singleton visibility); one `PageStart.qml` missing-property warning at line 344 (`isTabBarHidden`) remains to investigate. Static lint is not runtime verification.
- Resources: disk remains about 2.1 GiB free (96% used), RAM available about 2.2 GiB, 8 GiB swap with about 1.8 GiB used. No new full APK build was run because previous packaging nearly exhausted disk. The last verified APK does not include this Store screen update.
- Backend limits remain: live catalogue was previously confirmed empty (`[]`); purchase, authentication, order/payment, and provisioning APIs are not implemented. Store selection remains an informational dialog, not a fake purchase.
- Next: inspect/fix the remaining `PageStart.qml` warning if safe, add UI string localization for the custom screens, then plan a rebuild only after reclaiming safe disk space. No production panel/container changes were made.


## 2026-10-16 22:24 +0330 — Import/store debugging pass
- **Import review error path:** added a visible error banner to `PageManubisImportReview.qml`. On `ImportController.importErrorOccurred`, the screen now clears the busy indicator, resets the importing state, and explains that the configuration could not be saved; retry clears the previous error. This fixes a silent-failure path.
- **Avoid misleading subscription claims:** changed the Home drawer action from “Add subscription” to “Add connection”. Updated the Account screen to describe the actually supported import flow (VPN key/config) rather than implying subscription URLs already work. Subscription URL parsing remains intentionally unimplemented pending a verified backend contract.
- **Store API exposure investigation:** live `GET /store-api/api/v1/store/plans` returns HTTP 200 with `[]`. `GET /store-api/api/v1/store/settings` returns nginx 404. Read `/etc/nginx/conf.d/qoqnus.conf`: the public reverse proxy intentionally exposes only the exact plans endpoint and returns 404 for all other `/store-api/` paths. The backend source has a public settings route, but the current Nginx allow-list deliberately keeps it private. I did **not** widen the public API surface or change/reload Nginx without explicit approval. The app no longer requests the unavailable settings route at startup or on refresh, avoiding repeated 404 requests. Store settings/maintenance/support remain unavailable in the Android client until the endpoint is intentionally exposed.
- **Validation:** `git diff --check` passes. `qmllint` ran against the 8 custom pages and `PageStart.qml`; no syntax/fatal/compile errors. It reports 267 warnings overall, mostly existing unqualified accesses/C++-registered objects. The known `PageStart.qml` warning for `currentItem.isTabBarHidden` remains; the attempted dynamic-lookup workaround was reverted because the static checker still warned and it did not improve behavior.
- **Build/runtime:** no new Android build run; root filesystem still has about 2.1 GiB free (96% used), RAM available ~2.2 GiB, swap 8 GiB with ~1.8 GiB used. No Android device attached, so runtime behavior remains unverified. The previous APK does not include these newest changes.
- **Next:** decide/authorize whether the non-sensitive public store-settings route should be added to the Nginx allow-list; complete translations; continue import/runtime testing; reclaim disk safely before another serial release build. No production container/service was changed.

- **Checkpoint:** committed the import/store debugging changes as local commit `b50bffce` (`fix(android): clarify import flow and surface save errors`). Working tree is clean on `feature/manubis-ui-rebuild`. GitHub push is still not confirmed because this shell has no authorized HTTPS Git credentials.


## 2026-10-16 23:05 +0330 — Language selector and regression checks
- Fixed first-open state in `PageManubisLanguage.qml`: if no Manubis-specific language code was saved yet, the selector now highlights the language actually active in `LanguageUiController` (Persian index 4, Russian index 1, otherwise English index 0). This prevents an apparently unselected language screen for existing installs.
- Re-ran `qmllint` for the language page: no syntax/fatal/compile diagnostics. `git diff --check` passes.
- Tried to run store-backend tests, but `pytest` is not installed in the project environment and no local `pytest` executable was found. Did not install packages or alter the deployed backend/services.
- No APK build: disk remains ~96% full with ~2.1 GiB free, and no Android runtime device is attached. No changes to Nginx or production containers.
- **Checkpoint:** language selector fix committed locally as `b24f114d` (`fix(android): highlight active language on selector`). Working tree is clean on `feature/manubis-ui-rebuild`; no GitHub push confirmed.


## 2026-10-16 23:42 +0330 — Configurable Store API and build verification

- **UI implementation:** added a persistent Store API base URL field to the Manubis VPN Settings page. It validates HTTPS and whitespace, strips trailing slashes, stores the endpoint using Qt Quick Settings (ManubisGuard/storeApiBaseUrl), and provides a direct route to the Store page. The Store page now reads the same persisted setting and fetches plans from that configurable endpoint.
- **Store cleanup:** removed the unused settings request and dead store-settings properties because the public reverse proxy deliberately exposes only the plans endpoint. Removed stale maintenance-mode branches that could never be populated and corrected the misleading initial status message. No Nginx rules or production services were changed.
- **Home accuracy:** renamed the data tile from MONTHLY FREE DATA to DATA USAGE; the app still has no verified customer quota endpoint, so no quota values are fabricated.
- **Static validation:** qmllint across the 8 custom Manubis pages plus PageStart.qml exited 0, with zero syntax/fatal diagnostics. It reports 270 warnings, mainly the existing standalone import-path and unqualified-access warnings. git diff --check passes.
- **Build attempt:** native library and QML resource compilation succeeded. APK packaging failed because the build shell did not have the required QT_ANDROID_KEYSTORE_PATH, QT_ANDROID_KEYSTORE_STORE_PASS, and QT_ANDROID_KEYSTORE_ALIAS environment variables, causing Gradle packageOssRelease to report missing storeFile. A first overlapping retry also failed due Gradle observing missing intermediate JARs; the builds were stopped and then retried serially. The serial build still stopped at signing configuration, not source compilation.
- **Artifact safety:** the expected oss/release/android-build-oss-release.apk output was removed by Gradle's failed packaging task. The last previously signed artifact remains available at /opt/manubisguard-build/android-arm64/client/android-build/AmneziaVPN.apk and /root/ManubisGuard-test.apk (SHA-256 9d7cb34641b40ebd34de5e98ee0e06d59d9b1c18c340b5887c6c3f6eefe341a6 for the root test APK). Its signer matches the existing public test APK certificate fingerprint 3cebeaab17047b2bf9d30d69259d5df69a2e48268cc7ecc96709a27a5d85cc3a. These APKs predate the latest source changes; they were not republished, overwritten, or misrepresented as current.
- **Git checkpoint:** committed local source changes as 2637cc69 (feat(android): persist configurable store API endpoint). Working tree is clean on feature/manubis-ui-rebuild. GitHub push remains unconfirmed; no credentials were guessed.
- **Still blocked / not release-ready:** recover the authorized test-signing environment for the existing certificate before packaging another update; install and run on a real Android device to verify the Android 16 Qt Quick renderer workaround and navigation; finish full fa/en/ru localization; implement customer authentication, real quota/usage, subscription URL parsing, orders/payment/verified fulfilment, and a secure admin/panel adapter before claiming store purchases or subscriptions work. The live public plans API currently returns []. No public APK URL or production panel/service was changed.


## 2026-10-16 23:46 +0330 — Signed OSS APK rebuilt and verified

- **Build recovery:** recovered the existing test-signing configuration from the protected local build secret file (/opt/manubisguard-build/keystore.pass) without exposing the password in logs. Rebuilt serially with the existing test keystore and alias; CMake/Gradle finished successfully: BUILD SUCCESSFUL, 331 actionable tasks, 178 executed, 73 cached, 80 up-to-date.
- **Current candidate:** /opt/manubisguard-build/ManubisGuard-ui-test-20261016.apk (also at /opt/manubisguard-build/android-arm64/client/android-build/build/outputs/apk/oss/release/android-build-oss-release.apk). Size about 74 MiB. SHA-256: eba1d742edf9a9ab0ea436a9aed08b0b8fc951390cefea19287c3e72bc1f85fe.
- **APK validation:** apksigner v2 verification passed; one signer; certificate SHA-256 3cebeaab17047b2bf9d30d69259d5df69a2e48268cc7ecc96709a27a5d85cc3a, matching the existing test APK certificate. aapt confirms package org.manubisguard.vpn, label Manubis Guard, versionCode 2173, versionName 5.1.0.0, min SDK 28, target SDK 36. unzip integrity check passed.
- **Resource cleanup:** removed only regenerable playRelease intermediates after the successful build; preserved OSS intermediates, both packaged flavor APK outputs, native debug symbols, keystores, prior test APKs, and the new candidate. Root filesystem free space improved from about 960 MiB to about 2.1 GiB. No application services were stopped.
- **Publication/runtime:** candidate is intentionally kept private on the build host; the public download URL and /var/www artifacts were not changed. No ADB/physical Android device is available, so install, launch, Android 16 renderer behavior, navigation, and visual checks remain unverified. Do not call this a release-ready build until device testing succeeds.


## 2026-10-16 23:59 +0330 — Shared preferences fix and final signed candidate

- **Shared-settings correctness fix:** replaced separate per-page Qt Quick Settings objects with the ManubisPreferences singleton, so the Store page and Settings page read/write the same live preference instance. Fixed a QML singleton warning by declaring the Settings object as an explicit property instead of an invalid child of QtObject. The singleton is registered in Manubis/qmldir and included in qml.qrc.
- **Rebuild:** rebuilt the Android native target; the QML resource was regenerated and compiled, and the native shared library linked successfully. Copied the updated library into the Gradle JNI input directory and ran only assembleOssRelease to avoid rebuilding the unused Play flavor. Gradle succeeded: 247 actionable tasks, 8 executed, 239 up-to-date.
- **Final candidate artifact:** /opt/manubisguard-build/ManubisGuard-ui-test-20261016.apk; output path is /opt/manubisguard-build/android-arm64/client/android-build/build/outputs/apk/oss/release/android-build-oss-release.apk. SHA-256: 5fbbcb803b5819c289c17b9502d3659ee206afcea23d21569063946631e9a9c4. This supersedes the earlier candidate hash eba1d742… recorded above.
- **Final static checks:** full qmllint over ManubisPreferences, all 8 custom Manubis pages and PageStart exited 0 with 0 syntax/fatal diagnostics and 270 warnings, primarily existing unqualified-access and import-path warnings. The new singleton has no remaining qmllint warning. git diff --check passes; working tree is clean.
- **Final APK checks:** APK Signature Scheme v2 verification passed; signer SHA-256 remains 3cebeaab17047b2bf9d30d69259d5df69a2e48268cc7ecc96709a27a5d85cc3a. Package org.manubisguard.vpn, label Manubis Guard, version 5.1.0.0 / versionCode 2173, min SDK 28, target SDK 36. ZIP integrity passes.
- **Limits unchanged:** this candidate is private and not published. There is still no physical Android device/ADB runtime verification, no customer authentication/quota/real checkout or fulfillment API, and the live public plans API returns an empty list. Do not describe the app as fully production-complete until those blockers are addressed.


## 2026-10-17 00:07 +0330 — Final repository checkpoint

- Final local source commit: a427367e (fix(android): attach persistent settings to singleton). Branch feature/manubis-ui-rebuild is clean; git diff --check passes.
- The current signed candidate SHA-256 is 5fbbcb803b5819c289c17b9502d3659ee206afcea23d21569063946631e9a9c4 and its APK signature/package/ZIP checks pass as recorded above. It was built from the source tree containing the a427367e code fix, but the compiled diagnostic GIT_COMMIT_HASH remains 333f6735 because the final source commit was created after native linking. This affects only embedded build-identification metadata, not the QML resource content; rebuild after commit if a clean release provenance is required.
- Runtime availability check: adb devices reports no attached Android devices and emulator -list-avds returned no configured emulator. No install/launch test could be run. Public download and Nginx remain unchanged.


## 2026-10-17 — Shared QML preferences follow-up

- The shared persistent preferences singleton was corrected and committed in the working branch: `333f6735` (`share persisted store API preferences`) and `a427367e` (`attach persistent settings to singleton`). The settings page and store now reference the same `ManubisPreferences` instance instead of maintaining separate store endpoint values.
- Confirmed the native Android target completed successfully after regenerating QML resources: `libAmneziaVPN_arm64-v8a.so` linked successfully. The native build log shows all 222 steps completed, exit code 0.
- `qmllint` was run on `ManubisPreferences.qml`, `PageManubisSettings.qml`, and `PageManubisStore.qml`; it returned exit code 0 and showed warnings only (mainly unresolved `PageEnum` import path and unqualified existing controller/singleton references), no syntax or parse errors.
- Current blocker is final APK repackaging/signing after these latest singleton commits. The earlier signed candidate does not contain these newest changes, and no public APK was replaced. Device runtime testing still requires a connected Android device; no ADB device was available in the prior checks.


## 2026-10-17 00:12 +0330 — Resume: APK artifact re-validation

- **Reconnect / repository:** resumed on CLY914129, project /opt/manubisguard-android; repository is on feature/manubis-ui-rebuild at a427367edcca2f797d63a945a979e368179c3a24. Working tree is clean and git diff --check passes.
- **Artifact re-validation:** checked /opt/manubisguard-build/ManubisGuard-ui-test-20261016.apk directly. SHA-256 remains 5fbbcb803b5819c289c17b9502d3659ee206afcea23d21569063946631e9a9c4; apksigner verify --verbose --print-certs succeeds with one signer and APK Signature Scheme v2; certificate SHA-256 is 3cebeaab17047b2bf9d30d69259d5df69a2e48268cc7ecc96709a27a5d85cc3a. aapt dump badging confirms package org.manubisguard.vpn, versionCode 2173, versionName 5.1.0.0, min SDK 28 and target SDK 36. unzip -t reports no compressed-data errors.
- **Resource status:** root filesystem has approximately 1.8 GiB free (97% used), RAM available approximately 895 MiB, and 8 GiB swap with about 3.6 GiB used. No overlapping or fresh full build was started, to avoid filling the disk. The existing signed candidate includes the latest shared-preferences QML/native resource changes according to the prior build record; its embedded diagnostic commit hash predates the final Git commit, which does not change the app's functional resources.
- **Runtime verification:** adb devices still reports no connected Android device, and no emulator is configured. Install/launch/navigation and Android 16 renderer behavior remain unverified. No public download URL, web root artifact, Nginx rule, or production service was changed.
- **Next step:** transfer this private candidate to the user's Android device for install/launch testing, then record crash/logcat and screen-flow results. If a fresh provenance-clean build is required, first reclaim more disk safely and perform one serial build only. Do not publish as release-ready until runtime testing passes.


## 2026-10-17 00:26 +0330 — Publish private-build candidate as a separate test download

- Copied the verified signed candidate to `/var/www/manubisguard-downloads/ManubisGuard-ui-test-20261017.apk`; preserved the pre-existing `ManubisGuard-test.apk` and its URL unchanged.
- Added one exact-match HTTPS Nginx location for `/downloads/ManubisGuard-ui-test-20261017.apk` with APK content type, attachment filename, `no-store`, and `nosniff` headers. Backed up `qoqnus.conf` before editing; `nginx -t` passed and Nginx reload succeeded.
- Public HTTPS check returned HTTP 200 with Content-Length 76,987,592 and the expected download headers. HTTP Range request returned 1,024 bytes successfully. SHA-256 of source and served artifact matches: `5fbbcb803b5819c289c17b9502d3659ee206afcea23d21569063946631e9a9c4`.
- This is explicitly a TEST APK, not release-ready. Device runtime testing remains outstanding. No VPN panel, backend, subscription routes, or existing download URL were changed.

## 2026-10-17 — Redmi/Xiaomi black-screen investigation and renderer-default candidate

- **User runtime symptom:** the signed `ManubisGuard-ui-test-20261017.apk` installed on Xiaomi Note 14 / Redmi `tanzanite_global`, but had several launch crashes and then opened to a blank black screen.
- **Evidence review:** the previously supplied Android 16 / HyperOS 3 tombstone was documented as `abort -> QMessageLogger::fatal -> libplugins_platforms_qtforandroid -> QOpenGLContext::makeCurrent -> QRhi::beginFrame`. This implicates the Qt Android graphics-surface/context path; it does not establish a QML page as the original cause. The prior APK intentionally forced `QSGRendererInterface::Software` as a diagnostic workaround, but that exact candidate now exhibits a blank UI on the user's device. No ADB device is attached to the build server, so a live logcat cannot be collected here.
- **Code correction:** removed forced Qt Quick software-renderer selection from `client/main.cpp`, restoring Qt's platform-default Android renderer. Removed `setPersistentSceneGraph(true)` and `setPersistentGraphics(true)` from `client/amneziaApplication.cpp`, so Qt can recreate graphics resources when Android tears down/recreates the surface. These are evidence-based changes to the renderer/lifecycle path, but their effectiveness is **not yet confirmed on the physical device**.
- **Build:** native target `ninja -C /opt/manubisguard-build/android-arm64 -j2 AmneziaVPN` succeeded (6/6 steps). Copied the resulting ARM64 native library into the Android Gradle JNI input and ran serial `assembleOssRelease`; `BUILD SUCCESSFUL` (247 actionable tasks, 8 executed, 239 up-to-date).
- **Candidate artifact:** `/opt/manubisguard-build/ManubisGuard-renderer-default-test-20261017.apk`; SHA-256 `26d21378b6b354be65b260eecbfdd8c88fde1600c0bc9a8543be6457d70ccce6`. APK signature v2 verified with the same test certificate SHA-256 `3cebeaab17047b2bf9d30d69259d5df69a2e48268cc7ecc96709a27a5d85cc3a`; package `org.manubisguard.vpn`, version 5.1.0.0 / code 2173, ARM64, min SDK 28, target SDK 36. ZIP integrity passed and the forced-software-renderer marker is absent.
- **Still required:** install this candidate as an update on the Xiaomi and test cold launch + background/resume. If black screen/crash persists, capture a fresh full Android bug report/logcat around launch, including the fatal message before the tombstone. Server has no attached device/emulator, so do not mark the crash fixed or release-ready based only on a successful build.
- **Git checkpoint:** committed the renderer/lifecycle patch locally as `cbe63886` (`fix(android): restore default renderer lifecycle`); branch `feature/manubis-ui-rebuild` is clean. No GitHub push was attempted.
- **Test distribution:** published this candidate separately as `/downloads/ManubisGuard-renderer-default-test-20261017.apk`; the existing `ManubisGuard-ui-test-20261017.apk` and its URL remain unchanged. Added an exact-match Nginx route, `nginx -t` passed, reload succeeded, and origin/external HTTPS checks with a cache-busting query returned HTTP 200. This is explicitly a diagnostic test candidate, not a confirmed fix. No panel/backend/container was changed.


## 2026-10-17 — Phase 2/3 continuation: shared onboarding state, store settings, honest UI states

- **On-device confirmation from user:** the renderer-default test APK launches successfully on Xiaomi Note 14. This confirms startup works on that device for the tested build; repeated cold-start/resume and VPN connect/disconnect have not yet been confirmed.
- **Shared language state fixed:** `PageStart.qml` and `PageManubisLanguage.qml` previously declared independent Qt `Settings` objects with the same category. Replaced those with the shared `ManubisPreferences` singleton and added a persisted `languageCode` alias. This ensures first-launch routing, language selection, and the Settings language shortcut read/write the same live preference instance.
- **Store now consumes backend presentation settings:** `PageManubisStore.qml` requests `GET /api/v1/store/settings`, reads only `store_name`, `store_description`, `support_url`, and `maintenance_mode`, and displays a maintenance banner / support link when configured. Store purchase controls remain disabled and explicitly state that online checkout is not active, rather than implying a purchase can be completed.
- **Account UI honesty:** disabled the decorative login button and made the missing authentication API status explicit. It no longer presents a modal as if a login attempt had occurred. Actual customer auth is still unimplemented; do not represent the account flow as complete.
- **Public API routing:** the backend already serves `GET /api/v1/store/settings` locally, but Nginx's public allowlist exposed only `/store/plans`. Added an exact-match public route for `/store-api/api/v1/store/settings`; verified external GET returns HTTP 200 and expected non-sensitive JSON. Verified `/store-api/api/v1/admin/settings` remains blocked by the Nginx catch-all (HTTP 404). Backed up `qoqnus.conf` before this phase's Nginx edit; `nginx -t` passed and reload succeeded.
- **Validation:** `qmllint` on ManubisPreferences, PageStart, PageManubisLanguage, PageManubisStore, and PageManubisAccount exits 0 with 0 parse/syntax errors (157 warnings, mostly existing unqualified references). The isolated store-backend smoke suite passed all 5 checks: liveness 200, admin page 200, public settings 200, public plans 200, unauthenticated admin plans 401. `health/ready` remains 503 because no panel API key is configured; no secret was invented or copied into the app.
- **Source commits:** `e687fb4c feat(android): unify onboarding and store settings`; `a3c78f85 chore(android): bump diagnostic test build version`. Version bumped to 5.1.0.1 / Android versionCode 2174 so the next APK can update the user's already-installed 5.1.0.0 test build.
- **APK build in progress at time of this note:** CMake regenerated after the version/hash change and started a 222-step native rebuild. Must wait for completion, then rebuild/sign OSS APK serially, verify signature/package/version/ZIP/SHA-256, and publish as a separate test URL. Host disk is tight (~1.3 GiB free, 98% used); avoid parallel/full-flavor builds and clean only regenerable artifacts after validation.
- **Remaining phase gates:** customer authentication and secure session storage; verified subscription URL fetching/import; actual usage/free monthly quota and expiry API; admin quota policy and location visibility; orders/renewals and a real payment provider with signed verification/webhook and idempotent provisioning; full fa/en/ru localization; real panel credentials/permissions and template mapping; physical-device tests of connect/disconnect, location switching, network loss and lifecycle. The production panel/database and payment state have not been changed.


## 2026-10-17 — Phase 3 test APK build/publish complete

- **Native build:** after CMake reconfigure, the Android ARM64 native target completed all 221 steps successfully in 398 seconds. This rebuild was required because the diagnostic build ID changed after the source commits. Compiler emitted existing deprecation / ignored-return warnings but no build errors.
- **APK build:** serial `assembleOssRelease` succeeded twice; final pass `BUILD SUCCESSFUL` (247 actionable tasks, 18 executed, 229 up-to-date). APK uses the existing ManubisGuard test certificate.
- **Final test artifact:** `/opt/manubisguard-build/ManubisGuard-ui-phase3-test-20261017.apk`, copied to `/var/www/manubisguard-downloads/ManubisGuard-ui-phase3-test-20261017.apk`. Package `org.manubisguard.vpn`, display name `Manubis Guard`, versionName `5.1.0.0`, versionCode `2174`, ARM64, min SDK 28, target SDK 36. Signature v2 verification passed; signer fingerprint remains `3cebeaab17047b2bf9d30d69259d5df69a2e48268cc7ecc96709a27a5d85cc3a`. `unzip -t` passed.
- **SHA-256:** `6a4e05e4345c4754e83337d05f8e92f7ad912ab32b97da1c10b1ffcaf4aad1ed`. Web-root file hash matches build artifact. Public HTTPS GET to `/downloads/ManubisGuard-ui-phase3-test-20261017.apk?nocache=2` returned HTTP 200, 76,987,276 bytes, APK MIME type.
- **Store API routing verification:** public `GET /store-api/api/v1/store/settings` returns HTTP 200 with only non-sensitive presentation fields; `/store-api/api/v1/admin/settings` remains HTTP 404 through Nginx allowlist. Existing public plans route unchanged and currently returns an empty list.
- **Repository:** Android branch `feature/manubis-ui-rebuild` is clean. Latest commits: `cbe63886` renderer lifecycle, `e687fb4c` shared onboarding/store settings, `a3c78f85` version-code build bump, `2dbc3978` versionName aligned with compiled native version. No GitHub push or PR was performed.
- **Important verification boundary:** user confirmed only that the prior renderer-default APK opened on Xiaomi Note 14. The just-published phase-3 APK has not yet been installed/run on the phone. It is still a TEST build, not production/release-ready.
- **Host pressure:** root disk remains ~98% used with ~1.3 GiB free; no further full native build should start until disk space is safely recovered or the next changes are ready to batch.

### Phase status after this checkpoint
- Phase 0 baseline/backups: completed earlier.
- Phase 1 startup: launch confirmed by user for renderer-default build; repeated launch/resume/connect/disconnect remains pending.
- Phase 2 design/navigation inventory: partial; route inventory found legacy Amnezia routes still referenced internally. Need route-by-route verification/remapping before claiming old UI is unreachable.
- Phase 3 onboarding/shell: shared language preference state fixed; UI shell exists; fa/en/ru localization is still incomplete.
- Phase 4 VPN home/location picker: UI calls the retained connection controller and local saved-server model; live VPN connect/disconnect/location switching has not been device-tested. Dynamic server inventory from panel is not implemented.
- Phase 5 account/import/quota: import of supported pasted configs exists; arbitrary subscription URL fetching, customer authentication, monthly free quota, usage and expiry API are not complete.
- Phase 6 store/renewal: plans and public store settings are read from backend; no active plans currently exist; purchase buttons are intentionally disabled until real payment verification and provisioning exist.
- Phase 7 admin: test backend can manage store plans/settings and panel connection, but customer quota policy/location visibility admin features, audit log/rate limiting and verified production panel credentials remain outstanding.
- Phase 8 QA/release: static lint, smoke tests, APK signing and download verification pass. Physical-device validation of this new phase-3 APK and VPN runtime cases remain outstanding.


## 2026-10-17 — Phase 2 route containment and operation-status UI (source checkpoint; build pending)

- Added `PageManubisOperationStatus.qml` and registered `PageManubisOperationStatus` in `PageEnum`/`qml.qrc`. It gives legacy install/deinstall/update callbacks a Manubis-branded progress surface, handles install success/server-busy/already-exists signals, and returns to the branded home screen on completion.
- `PageStart.qml` now redirects `PageSetupWizardInstalling` and `PageDeinstalling` to the custom operation page; `PageProtocolRaw` and `PageUpdate` to Manubis Settings; keeps existing routes for Home, Share, Settings, protocol settings, import/review, and language routed into the Manubis UI. The tab bar is hidden during the operation status screen. Global operation callbacks were reconciled to avoid duplicate completion toasts/navigation.
- Hardened Store API base URL input to reject credentials, query/fragment parts, and common local/private IPv4/localhost destinations. The support URL action now only opens HTTPS URLs. (Private IPv6 host rejection still needs a follow-up check.)
- `qmllint` for PageStart, PageManubisOperationStatus, PageManubisSettings and PageManubisStore completed with exit code 0 and zero parse/syntax errors; `git diff --check` passed.
- Committed locally as `83541665 feat(android): route legacy operations into Manubis UI`. Branch is clean.
- **Build intentionally pending:** this route-containment change occurred after the published phase-3 APK. It is source-only until batched with the next phase changes. Root disk is ~98% used; do not start another full native rebuild until additional phases are ready to batch and safe disk recovery is performed.
- **Remaining risks:** operation status has only static QML validation, not device runtime validation. The project still has legacy components referenced internally by the retained VPN core; the public navigation route map now redirects identified legacy page requests, but the old UI is not yet proven unreachable under every internal callback.


## 2026-10-17 — Route-containment build resolved and published

- First native compile attempt failed because `/opt/manubisguard-build/android-arm64/client/ui/utils/pageEnum.h` was a stale generated copy without the newly added enum value. The MOC source had the new value, but a prior include of the stale copied header defined `PAGE_ENUM_H`, causing the compiler to see an enum missing `PageManubisOperationStatus`.
- Corrected the generated build-tree header by copying the current source `client/ui/utils/pageEnum.h` into the generated include tree, then reran Ninja. `ninja -C /opt/manubisguard-build/android-arm64 -j2 AmneziaVPN` completed all 161 steps successfully; only pre-existing warnings (deprecated Qt/OpenSSL/libssh APIs and ignored `nodiscard` returns) remained.
- Rebuilt OSS APK: `BUILD SUCCESSFUL` (247 tasks, 8 executed, 239 up-to-date). Verified package `org.manubisguard.vpn`, `versionName=5.1.0.0`, `versionCode=2174`, ARM64, min SDK 28, target SDK 36, v2 signature valid, ZIP integrity clean. Embedded native resource contains `PageManubisOperationStatus` and source build hash `83541665`.
- Published latest route-containment build at the existing phase-3 test URL: `https://all.qoqnusradio.top/downloads/ManubisGuard-ui-phase3-test-20261017.apk`. SHA-256 `1f4a7ad4998767cf8b5b24046990854c30b1aaff43a21cfc046b5a3281490cb9`; web-root file matches. External HTTPS GET with cache-buster returned HTTP 200 and 76,987,556 bytes.
- Ran backend smoke script again: all 5 checks passed locally (health live, admin UI, store settings, store plans, unauthenticated admin plans). Public settings route returns HTTP 200; public admin settings route remains HTTP 404. The test backend still has no configured panel API key, so panel readiness, customer provisioning, and usage/quota remain unverified.
- QML lint across custom Manubis pages returned zero syntax/parse errors. No ADB device is connected to the build server, so the new route-containment APK has not been physically tested on Xiaomi Note 14. User previously confirmed only the renderer-default APK opens.
- Latest source commit remains `83541665 feat(android): route legacy operations into Manubis UI`; working tree is clean. No GitHub push was performed.


## 2026-10-17 — Manual card-to-card checkout + receipt review (implementation checkpoint)

### Backend and admin dashboard
- Added migration `0005_card_transfer_orders` and applied it to the isolated `manubisguard-store-test` database. It adds card-transfer configuration to `store_settings`, receipt metadata/data and a hashed per-order upload token to `store_orders`, and order states `pending_review` / `rejected`.
- Added admin-configurable card-transfer fields: enable/disable, cardholder name, card number, bank name and payment instructions. Card details remain blank and payment is disabled by default; no real card details were supplied or inserted.
- Added public `POST /api/v1/store/orders` to create a pending order and return a one-time high-entropy receipt token plus the configured card-transfer instructions. Added `POST /api/v1/store/orders/{id}/receipt` with token validation, a 5 MiB limit, base64 validation and strict JPEG/PNG/WebP/PDF content-signature checks. Receipt binary is stored in PostgreSQL, not a public filesystem path.
- Added admin-authenticated `GET /api/v1/admin/orders`, `GET /api/v1/admin/orders/{id}/receipt`, and `POST /api/v1/admin/orders/{id}/review`. Admin can inspect a receipt and approve/reject it. Approval transitions to `paid_pending_provisioning`; it deliberately does NOT claim to provision a VPN subscription while panel credentials/provisioning are still unconfigured.
- Expanded the Persian admin dashboard with card-transfer configuration and order/receipt review. Admin API calls use the `/store-api/api/v1/admin/...` proxy path and still require the `ADMIN_API_TOKEN` bearer token.
- Added exact Nginx allowlist routes for order creation, receipt upload, admin page and authenticated admin API. Upload requests are capped at 8 MiB at Nginx and checkout/receipt routes have a per-IP rate limit. Admin API remains 401 without a bearer token; unrelated `/store-api/` paths remain blocked by the catch-all.
- `nginx -t` passed and reload succeeded. Public checks: admin page 200, public settings 200, unauthenticated admin settings 401, order creation 503 while card-to-card is unconfigured, receipt upload 401 without the per-order token.
- Backend test suite: 57 passed. Existing backend smoke suite: 5/5 passed. Admin inline JavaScript `node --check` passed. Backend Python compile check passed.

### Android client
- Added a card-transfer checkout flow to `PageManubisStore.qml`: enter phone/Telegram reference, create order, display amount/cardholder/card/bank/instructions, copy card number, select a receipt file, optionally include transfer reference, and upload the receipt with the order token.
- Added `SubscriptionUiController.readLocalFileForUpload()` to read a selected local receipt file, enforce a 5 MiB maximum, detect allowed MIME types and return base64 for the upload request.
- Bumped app version to `5.1.0.2`, Android version code `2175`.
- `qmllint` on `PageManubisStore.qml` exited 0 with no syntax/parse errors (18 warnings). Native ARM64 target rebuilt successfully (41 Ninja steps), including the receipt helper and QML resources.
- Android Gradle `assembleOssRelease` reached packaging but failed because the signing config was not injected into this process: required `storeFile` is missing (`QT_ANDROID_KEYSTORE_PATH` and related signing environment are absent). Do NOT distribute the stale APK or the unsigned output as an installable test APK. No new APK was published. Do not ask for signing passwords in chat; restore the signing environment securely on the build host, then rerun packaging/signature verification.
- No physical Android device is attached to the build host. File-picker behavior, receipt upload from Android, copy-to-clipboard, full checkout UI and background/resume remain unverified on Xiaomi Note 14.

### Checkpoint / boundaries
- Android source committed locally on `feature/manubis-ui-rebuild` as `5a8bf76b` (`feat(android): add card transfer checkout and receipt upload`); working tree clean at commit. No GitHub push was performed.
- Backend source under `/opt/manubisguard-android/store-backend` is currently local deployment source, not part of the Android Git repository. Preserve this folder and migration; no remote backend repository was configured.
- The running service is the isolated `manubisguard-store-test` backend. Its card-transfer switch is OFF and card fields are blank. Do not treat this as production payment setup.
- Remaining: restore secure APK signing environment and build a fresh signed APK; physically test receipt file selection/upload on Android; test full manual order/receipt/admin review with synthetic data; decide whether admin receipt notifications should also be sent to Telegram (no Telegram admin destination/token was configured); connect real panel credentials and implement safe subscription provisioning after admin approval; complete customer account/subscription/usage flows.
- Prepared `/opt/manubisguard-build/build_manubisguard_card_transfer_apk.sh` as a repeatable signed-build wrapper. It checks for the three existing `QT_ANDROID_KEYSTORE_*` environment variables without embedding secrets, rebuilds the native target, runs Gradle, verifies APK signature/ZIP/metadata and prints SHA-256. It was not run because the secure signing environment is currently absent.


## 2026-10-17 — Receipt-picker debugging and native rebuild

- Found a real Android-specific bug in `SubscriptionUiController::readLocalFileForUpload()`: Android document pickers can return `content://` URIs, but the earlier implementation passed that URI to `QFile`, which cannot read Android's Storage Access Framework streams. This would make receipt upload fail on common Android file pickers even though QML parsed.
- Fixed Android `content://` reads using `ContentResolver.openInputStream()` via Qt JNI. The stream is read in bounded 8 KiB chunks; uploads above 5 MiB are rejected while streaming. MIME type is checked from file bytes, and a safe filename extension is inferred for URI-backed files. Ordinary local file URLs retain their existing path.
- First compile exposed a missing `QNativeInterface` include path. Removed the invalid include and relied on the Qt Core application headers used by the project; native ARM64 compile then passed, including `subscriptionUiController.cpp` and final link of `libAmneziaVPN_arm64-v8a.so`.
- QML lint: exit 0, zero syntax/parse errors. `git diff --check` passed.
- Backend suite rerun in an ephemeral test container: 57 passed in 1.28s. Local smoke tests: 5/5 passed. Public routes: store settings 200, admin page 200, admin API without bearer token 401.
- Signing issue remains: the previous `assembleOssRelease` attempt produced the unsigned APK and stopped because Gradle did not receive its signing environment. The Android SDK signing tool exists at `/opt/android-sdk/build-tools/36.0.0/apksigner`; the old published APK signer is `CN=ManubisGuard Test, OU=Development, O=ManubisGuard, C=DE` with SHA-256 certificate digest `3cebeaab17047b2bf9d30d69259d5df69a2e48268cc7ecc96709a27a5d85cc3a`. Do not replace the signing key or distribute the unsigned APK. Fresh signed APK and on-device verification remain pending.
- Disk remains critically constrained at about 98% used (around 1.1 GiB free); no cleanup of user data or build cache was performed.


## 2026-10-17 — Fresh native rebuild and stale Android version metadata fix

- Re-ran CMake configure after commit `0c3074cc`; CMake had been using an old cached configuration and the native build metadata previously embedded `83541665`. A fresh configure updated `GIT_COMMIT_HASH` to `0c3074cc` and triggered a complete ARM64 rebuild. All 221 Ninja steps completed successfully; final native library links without errors.
- Found another stale-build issue: despite `CMakeLists.txt` specifying app version `5.1.0.2` and Android version code `2175`, the generated Gradle `AndroidManifest.xml` still held `5.1.0.0` / `2174`. Updated the generated manifest and made the build wrapper do the same after CMake configure. The wrapper now removes the stale `processOssReleaseManifestForPackage` output before Gradle packaging.
- Verified `./gradlew --no-daemon processOssReleaseManifestForPackage` succeeds and the regenerated packaged manifest + metadata both show `versionName=5.1.0.2`, `versionCode=2175`.
- `assembleOssRelease` has not been rerun successfully because its signing environment is still unavailable in this execution context. Existing APK outputs on disk are stale (`2174` / `5.1.0.0`) and unsigned or signed from prior builds; do not publish them as this version. No new APK has been uploaded.
- Latest native library contains build identity `0c3074cc`. Disk still has only about 1.1 GiB free (98% used). No cache cleanup or user data deletion performed.

## 2026-10-17 — GitHub backup/push attempt

- Confirmed Android source repository: `/opt/manubisguard-android/android`, branch `feature/manubis-ui-rebuild`, HEAD `0c3074cc` (`fix(android): read receipt files from content URIs`), working tree clean before this note.
- Remote is `https://github.com/ManubisGuard/manubis-client.git`. A push was attempted, but Git over HTTPS has no configured credential and fails with `fatal: could not read Username for 'https://github.com': terminal prompts disabled` when prompts are disabled. The interactive attempt timed out waiting for credentials; no refs were changed on GitHub.
- GitHub connector reports authenticated account `arsamnikzaad` has `pull: true` and `push: false` on `ManubisGuard/manubis-client`. Thus this is an authorization blocker, not a source/build failure. Do not try to bypass access controls or expose credentials in chat.
- Required next action: grant `arsamnikzaad` write access to `ManubisGuard/manubis-client`, or securely restore a write-enabled GitHub credential on CLY914129. Then push `feature/manubis-ui-rebuild` and verify the remote head SHA is `0c3074cc` or a newer commit.
- Project-level files outside the Android Git repository (`todo.md`, `docs/`, `store-backend/`, `tools/`, `PROJECT_BRIEF.md`) are not covered by that remote. Before publishing them, exclude secrets such as `store-backend/.env`, inspect for credentials/customer data, and decide whether to add them to a dedicated private repository or a sanitized project-backup repository. Do not publish `.env` or production secrets.
- Disk remains critically full (~98%, ~1.1 GiB free); avoid large bundle/archive or full rebuild until space is safely recovered.

## 2026-10-17 — Safe disk cleanup (pre-cleanup assessment)

- User explicitly authorized cleanup of unnecessary files to recover disk space; project continuation and reporting must be preserved.
- Baseline root filesystem: 50G total, 46G used, 1.1G available (98%); inode use 23%.
- Largest observed reclaimable candidates: Docker build cache 5.677GB total / 3.392GB reclaimable; `/root/.gradle/caches` 2.7GB (kept because Android builds depend on it); `/opt/manubisguard-build` 2.3GB (kept because it contains the current Android ARM64 build tree); Puppeteer browser cache 670MB (kept because potential browser automation dependencies are unknown); Docker unused volumes 475MB (kept because volumes may contain state/data).
- Docker has 20 images and 24 active containers. No images, volumes, project source, Git history, APKs, signing materials, databases, or user data will be removed in this cleanup.
- Planned safe actions: prune Docker's unused build cache only, vacuum systemd journal to 100MB, and clear package-manager/pip download caches. Recheck disk usage and core services afterward.

## 2026-10-17 — Safe disk cleanup (execution)

- Cleanup was limited to regenerable Docker build cache, archived journal history above the 100MB target, apt package archives, and pip HTTP download cache.
- Preserved Android source/build output, Gradle caches, Puppeteer browsers, Docker images, all Docker volumes, running containers, backend data, project backups, signing assets, and Git metadata.
- Exact reclaimed space and post-cleanup filesystem/service checks are recorded in the command output from this run; the follow-up check below will append final verified numbers.

## 2026-10-17 — Safe disk cleanup (verified results)

- Reclaimed approximately 5.0GB of filesystem space: root filesystem improved from 46G used / 1.1G free (98%) to 41G used / 6.1G free (88%).
- Docker build cache reduced from 5.677GB (3.392GB reported reclaimable) to 0B; no image/container/volume was removed.
- Systemd journal reduced from 334.8MB to 99.9MB; 234.8MB archived journal history was removed. Active logs were retained.
- Cleared apt archive cache and pip HTTP download cache only.
- Kept `/opt/manubisguard-build` (2.3GB), Android Gradle cache (2.7GB), Puppeteer browser cache (670MB), Docker images, volumes, active containers, source, Git history, APKs and signing materials intact.
- Follow-up checks: recorded filesystem now has ~6.1GB free. Android Git worktree and `git diff --check` checked; active container status, remote branch SHA, native/APK artifact presence, and signing environment presence were inspected. Secret values were not printed.
- Note: future Docker image builds may take longer because disposable BuildKit cache was removed. No application container was restarted by this cleanup.

## 2026-10-17 — Post-cleanup continuation checkpoint

- Confirmed 24 Docker containers remain running; core ManubisGuard panel and TimescaleDB report healthy, as do store test API/database and Redis services. Cleanup did not restart containers.
- Android branch remains clean and local HEAD matches GitHub `feature/manubis-ui-rebuild` at `0c3074ccd25d`.
- The native ARM64 library build output exists from the latest native rebuild, but the APK files found on disk have older timestamps (2026-10-16); they are not evidence of a fresh package containing all latest changes.
- Release signing variables are absent in the current execution environment. Do not run a release signing step or claim a fresh signed APK until the existing signing keystore and secure credentials are restored. A path-only scan for keystore files was performed; no credential values were printed.
- Next work item remains: safely restore access to the existing signing key (without rotating it), produce and verify a fresh signed APK, then physically test receipt `content://` selection/upload. Backend production provisioning and real payment configuration remain separate incomplete tasks.
- Signing follow-up detail: two root-only keystore files remain present and untouched: `/opt/manubisguard-build/manubisguard-test.keystore` and `/opt/manubisguard-build/manubisguard-test-v2.keystore` (both mode 0600). The expected `QT_ANDROID_KEYSTORE_*` variables are not set in the current shell. A filename-only scan for config files referencing `QT_ANDROID_KEYSTORE_PATH` was performed; no secret values were printed. Do not guess a keystore password, rotate keys, or overwrite either keystore. Identify the correct existing keystore and restore its credentials through the server's secure environment before signing.
- Signing follow-up detail: two root-only keystore files remain present and untouched: `/opt/manubisguard-build/manubisguard-test.keystore` and `/opt/manubisguard-build/manubisguard-test-v2.keystore` (both mode 0600). The expected `QT_ANDROID_KEYSTORE_*` variables are not set in the current shell. No secret values were printed. Do not guess a keystore password, rotate keys, or overwrite either keystore. Identify the correct existing keystore and restore its credentials through the server's secure environment before signing.

## 2026-10-17 — Continued verification after cleanup

- Re-ran isolated store backend smoke suite: all five checks passed (`/health/live` 200, `/admin` 200, public store settings 200, plans 200, unauthenticated admin plans 401). This confirms only the isolated test deployment; it does not validate payments, real panel credentials, or customer provisioning.
- Inspected existing APK metadata and signature. Files currently available on disk are old builds (`versionCode=2173`, `versionName=5.1.0.0`, timestamps 2026-10-16), so they must not be distributed as the current source version (`5.1.0.2`, code 2175).
- Confirmed no Android device/emulator is attached to the build host (`adb devices` empty), so physical install and receipt-upload testing cannot be done from this host right now.
- Rechecked filesystem: 6.1GB free (88% used). Android source repository remains clean and local HEAD equals GitHub branch HEAD at `0c3074ccd25d`.
- Current blocker for fresh signed APK is secure signing configuration: `QT_ANDROID_KEYSTORE_PATH`, `QT_ANDROID_KEYSTORE_ALIAS`, and `QT_ANDROID_KEYSTORE_STORE_PASS` are missing from the current environment. Existing keystore files remain intact and mode 0600. Do not guess passwords or rotate the signing identity. Next step is to identify the correct existing keystore and securely restore its passphrase/alias in the build environment, then run the prepared wrapper and verify resulting APK package metadata, signature digest, ZIP integrity, and SHA-256.
- Final build-wrapper preflight: attempted the prepared wrapper once after verification; it stopped immediately at its explicit preflight check because secure  is missing (exit 1). No build/signing operation was started and no output APK was overwritten.
- Report correction: the previous shell heredoc expanded inline backticks while recording the preflight result, so that single sentence omitted the variable name and the shell emitted a harmless `command not found` diagnostic after the build wrapper had already exited. The actual wrapper output explicitly reports missing `QT_ANDROID_KEYSTORE_PATH`; no build/signing operation started and no APK was overwritten.

## 2026-10-17 — Admin-to-app integration clarified and documented

- Confirmed the live HTTPS admin dashboard route responds HTTP 200 at `https://all.qoqnusradio.top/store-api/admin`.
- Confirmed the public store settings and plans endpoints respond HTTP 200, while the admin settings API without a bearer token responds HTTP 401.
- Confirmed Android defaults `ManubisPreferences.storeApiBaseUrl` to `https://all.qoqnusradio.top/store-api`; the Store screen reads `/api/v1/store/plans` and `/api/v1/store/settings` from this base URL. Settings also exposes a per-device API-base override. The app must never contain `ADMIN_API_TOKEN` or the panel API key.
- Added `docs/ADMIN_GUIDE_FA.md` documenting admin URL, safe role separation, manager login, adding plans, configuring card transfer, configuring panel API, and remaining production limitations.
- Important distinction: the web admin dashboard configures the backend; the Android app consumes only the public Store API. Updating a store setting/plan in the admin persists it in the backend database; the app sees it on its next API refresh. The current app/API path is aligned.
- Still incomplete: production-grade admin hardening/rate limits and audit logging; real panel API authentication and complete plan-to-template mapping; customer identity/subscription ownership; safe provisioning/renewal after confirmed payment; full end-to-end order/receipt/admin review; fresh signed APK and physical Android test. Receipt approval does not yet activate a subscription and must not be represented as full checkout readiness.
- No credentials were read or printed. No production panel data, card number, payment secret, or Android APK was changed in this step.

## 2026-10-17 — Store endpoint ownership/security correction

- Identified an architectural issue: the regular app Settings screen exposed a per-device editable Store API URL. This is not the same as the admin-managed main-panel API base and could let a user redirect the store UI to an untrusted endpoint.
- Removed the user-editable Store API address field and save handler from `PageManubisSettings.qml`; retained the Store information card and Open Store action.
- Made the public Store API base a fixed HTTPS client endpoint (`https://all.qoqnusradio.top/store-api`) in `PageManubisStore.qml` and removed the persisted override from `ManubisPreferences.qml`. The administrator changes the *main panel* Base URL and panel API key through the separate web dashboard; neither admin token nor panel API key is included in Android.
- Validation: `git diff --check` passed; `qmllint` for the two affected QML pages and preferences exited 0 with no syntax/parse/fatal errors. A pre-existing PageEnum import-path warning remains because this lint invocation lacks the app's generated import path. Native ARM64 target rebuilt successfully; qrc generation, QML resource compilation, and shared-library link all passed.
- Current live routing verified: `https://all.qoqnusradio.top/store-api/admin` = HTTP 200; public settings and plans = HTTP 200; admin settings API without token = HTTP 401. Isolated backend smoke suite passed 5/5.
- Secure config check reported `ADMIN_API_TOKEN` and `PANEL_SETTINGS_ENCRYPTION_KEY` configured, but `PANEL_API_KEY` missing/placeholder. No secret values were printed. Therefore the admin UI is reachable, but real panel API connectivity and automatic subscription provisioning cannot be considered ready until a least-privilege panel API key is safely configured and tested.
- Not yet done: full Android APK package/signing and on-device checkout testing; provisioning, customer identity, real payment lifecycle, admin audit log and production hardening remain blockers. No production subscription or payment was activated.

## 2026-10-17 — Store integration readiness check after endpoint ownership fix

- Live `GET /health/ready` returned HTTP 503. This is expected while the real panel API key/configuration is incomplete; do not mark backend ready for live provisioning.
- Live public plans endpoint returned HTTP 200 with 0 active plans. Public store settings returned HTTP 200; store name is `ManubisGuard Store`, card transfer is disabled, and no card number is configured. No test or real card data was inserted.
- This confirms the Android app can reach the configured public Store API, but a customer currently sees an empty catalogue and cannot complete a real purchase until an administrator safely adds active plans and configures payment.
- Android change committed locally as `ddb09d02` (`fix(android): keep store API endpoint centrally managed`). Local branch is one commit ahead of `origin/feature/manubis-ui-rebuild`; GitHub push is intentionally not attempted because the authenticated GitHub account previously had no push permission. `git diff --check` passed before commit; native ARM64 target and QML resource bundle rebuilt successfully.


## 2026-10-17 — Admin dashboard locked until successful authentication
- User requirement: do not display admin dashboard contents before the administrator provides valid credentials.
- Updated `store-backend/app/static/admin.html`: every privileged dashboard section is inside `#adminContent` with the HTML `hidden` attribute by default; the login card is the only dashboard content shown initially.
- Login now validates the submitted admin bearer credential against the protected settings endpoint before revealing the dashboard. Invalid credentials or a 401 response keep the dashboard hidden and clear the saved session token.
- Logout clears the session token and hides the dashboard; the panel API key input and card-number field are cleared. Requests use `cache: no-store`.
- Rebuilt and restarted `manubisguard-store-test-api-1` from `/opt/manubisguard-android/store-backend`.
- Verification: local `/health/live` 200; `/admin` 200 and `#adminContent` hidden by default; unauthenticated admin API 401; public settings 200. Same checks passed through `https://all.qoqnusradio.top/store-api`.
- Regression suite: 57 passed. JavaScript syntax check (`node --check`) passed.
- Security boundary remains: hiding the UI is not the authorization layer; admin API endpoints continue to enforce the server-side bearer token. This is still a shared admin-token login, not separate per-user accounts/MFA.
- Additional live verification: valid server-side admin token receives HTTP 200 from the protected settings API; dashboard response includes `Cache-Control: no-store`; deployed container reports healthy. Token value was not printed.

## 2026-10-17 — Account API and Android account flow
- Added customer-account models (`store_users`, `store_sessions`) and optional order ownership to the Store backend, with additive Alembic migration `0006_customer_accounts` applied to the current store-test database.
- Added `/api/v1/auth/register`, `/login`, `/me`, `/logout`, and `/me/orders`. Passwords use salted PBKDF2-HMAC-SHA256 with 310,000 iterations; bearer session tokens are random, only token digests are stored, sessions expire after 30 days, and logout revokes a session. Added 15-minute throttling for account registration/login and bounded in-process rate-limit state.
- Added Nginx allowlist route `/store-api/api/v1/auth/`, edge request limiting, no-store headers, and trusted `X-Real-IP` forwarding. Nginx syntax test passed and configuration reloaded. Public `GET /api/v1/auth/me` without a token returns 401; malformed registration input returns 422 when routed through the public endpoint.
- Rebuilt/restarted `manubisguard-store-test-api-1`; container is healthy and migration current is `0006_customer_accounts`.
- Android account screen is now connected to the account endpoints: login/register mode, password confirmation, in-memory-only session token, account profile, logout, and authenticated order history. Store checkout passes the bearer token when signed in so orders can be linked to the account. Dashboard account card now routes to the account page.
- QML lint scan found no syntax/type errors in the modified account/store/dashboard/preferences pages; pre-existing unqualified-access warnings remain. Native ARM64 Qt target rebuilt successfully after QML resource regeneration.
- Added four account security/validation unit tests. Full backend suite result is recorded after the final run below.
- Fresh Android debug test APK rebuilt: `/opt/manubisguard-build/ManubisGuard-5.1.0.2-debug-test.apk`; package `org.manubisguard.vpn`, version `5.1.0.2`, versionCode `2175`, target SDK 36, ARM64. APK signature verified with Android debug certificate, ZIP integrity passed, and embedded stripped native library hash matches the build artifact. This is a debug/test build, not a release-signed APK.
- Published the debug test APK at `https://all.qoqnusradio.top/downloads/ManubisGuard-5.1.0.2-debug-test.apk`; download returned HTTP 200 and 88,804,182 bytes. Debug signing identity differs from the old test APK; Android may refuse an in-place update if a differently signed build is already installed. Do not uninstall an existing app if its local data matters.
- Android source commit `35ec008a` (`feat(android): connect account auth and order history`) created locally. Branch `feature/manubis-ui-rebuild` is two commits ahead of GitHub. No push attempted because the authenticated GitHub account previously had no push permission.
- Still outstanding: full live registration/login/logout lifecycle test, physical Android runtime and receipt-picker/upload test (no device attached to build host), production signing key/credentials, account recovery/email verification/MFA, real panel API key, active catalogue/payment configuration, and safe panel provisioning/renewal. The current store-test backend still has zero active plans and card transfer disabled; do not accept real payments yet.

## 2026-10-17 — Final verification for account/API + debug APK phase
- Final backend regression suite after rate-limit and order-history query hardening: **61 passed**.
- Account API no-token check returns HTTP 401 and response includes `Cache-Control: no-store`; public store settings returns 200; public plans returns 200 with an empty list. No account credentials were created or printed during this validation run.
- Current store API container is `running/healthy`; database migration reports `0006_customer_accounts (head)`. Nginx syntax check passed after adding the auth route; public debug APK endpoint responds HTTP 200 with 88,804,182 bytes.
- QML parse/type-error scan is clean for changed pages; native ARM64 target linked successfully; debug APK metadata/signature/archive integrity checked and embedded stripped native library SHA-256 matches the Gradle stripped artifact.
- Android repository worktree is clean after commit `35ec008a`; branch is 2 commits ahead of `origin/feature/manubis-ui-rebuild`. The backend source is now also preserved in its own local Git repository at `/opt/manubisguard-android/store-backend`, commits `defb5b7` and `93d2a4e`; `.env` is ignored and no key/keystore/certificate files are tracked. This backend repository has no GitHub remote configured and has not been pushed.
- Honest remaining blockers: no full live register/login/logout lifecycle test has been run yet; no Android device is attached for runtime, VPN-connect, or receipt-upload tests; release signing key/password/alias are unavailable; the public store test database still has zero active plans, card transfer is disabled, and the real panel API key is missing. Email verification/recovery/MFA, panel subscription provisioning and renewals are not production-ready. Keep the published APK labelled debug/test only.
- Final verification after the last backend rebuild: regression suite remains **61 passed**; store API container and database healthy; migration `0006_customer_accounts` is current; account `/me` returns 401 without a token and `Cache-Control: no-store`; public settings 200; plans 200 (empty); debug APK download 200 with expected 88,804,182-byte payload.
- Reclaimed 765.2MB by pruning only regenerable Docker build cache after builds. No images, containers, volumes, source, Gradle caches, signing files, databases or APKs were removed. Root filesystem improved from 92% to 91% used, with 4.4GB free. ManubisGuard panel and TimescaleDB remained healthy.

## 2026-10-17 — App language synchronization + WireGuard/AWG config-file import

- Reworked custom Manubis account, dashboard, store, and connection-import/review screens so visible labels, validation errors, loading states, order states, checkout labels, and receipt-upload feedback follow the selected app language. Persian is used only when Persian is selected; English is used for English and unsupported custom-page locales.
- Added safe handling for server-provided text: if an English UI receives Persian-only store descriptions, plan names/descriptions, account order names, bank labels, or payment instructions, it uses a clear English fallback instead of leaking Persian text into the English interface. The client also reads optional `*_en` / `*_fa` fields when supplied by a future bilingual API response.
- Replaced the mixed Persian/Russian language-screen subtitle with language-aware copy and localized the import/review flow.
- Added a dedicated **Load configuration file (WireGuard / AmneziaWG)** action to Add Connection. It opens the existing Android document picker with filters for `.conf`, `.wg`, `.awg`, `.vpn`, `.ovpn`, `.json`, and `.txt`, then sends the selected file through the existing `ImportController.extractConfigFromFile()` parser and into the existing review/save flow. No AWG protocol engine or connection core was replaced.
- Build: native ARM64 Qt target rebuilt; `assembleOssDebug` completed successfully. Fresh APK metadata: `org.manubisguard.vpn`, version `5.1.0.2`, code `2175`, min SDK 28, target SDK 36, ARM64. APK v2 signature verified, ZIP integrity passed, and the embedded stripped native-library SHA-256 matches the Gradle stripped artifact (`18090cd1e87b4ddc09b5a01c6e5a45c1ebb79971aa01b978e8784b171721102a`).
- Published updated debug/test APK to `/downloads/ManubisGuard-5.1.0.2-debug-test.apk`; HTTP HEAD returned 200 and content length 88,808,582 bytes. New APK uses the same debug certificate as the previously published test APK, so the signature identity is unchanged for an in-place test update.
- `git diff --check` passed. No duplicate localization helper declarations remain in the modified pages. QML resource generation/native link and Gradle debug packaging passed. A standalone `qmllint` executable is not installed in this host environment, so do not claim a dedicated QML lint run for this change.
- Still not physically verified: Android document picker interaction, importing a real `.conf` AWG file, VPN connect/disconnect, language switching on-device, account registration/login UI, and receipt upload. No ADB device is attached to this build host. The APK remains debug/test, not a production release.
- Store production readiness remains blocked separately: the public catalogue currently has zero active plans, card transfer is disabled, real `PANEL_API_KEY` is not configured, and panel provisioning/renewal after payment has not been tested. Do not accept real payments or claim automatic activation is ready.

## 2026-10-17 — GitHub publication and pre-wipe source preservation

- Successfully pushed Android branch `feature/manubis-ui-rebuild` to `git@github.com:ManubisGuard/manubis-client.git`. Remote moved from `0c3074ccd25d71815d273a11c58a84933644987e` to `0480f054`; the three pending Android commits (centralized Store API endpoint, account auth/order history, bilingual UI + AWG file import) are now on GitHub.
- SSH authentication uses the existing root-only key at `/root/.ssh/manubisguard_github` explicitly with `GIT_SSH_COMMAND`; the default shell had no SSH agent and default identity selection failed. No key contents or credentials were displayed.
- To protect against the planned server wipe, the project brief, full progress log, documentation, design/tool assets, and source-only Store backend snapshot are preserved in the Android repository under `project-records/`.
- The Store backend snapshot was exported from tracked Git objects only; runtime `.env`, databases, live secrets, signing keys, APK/build caches, and live server data are excluded. The backend's two-commit Git history is preserved as `project-records/backups/store-backend-history.bundle`; `git bundle verify` confirmed the bundle is complete.
- The separate backend repository does not have its own GitHub remote/repository configured. Its source and history bundle are being committed into the Android repository so the backend can be recovered after the server wipe.
- Validation still required: inspect staged file list for secrets, commit these records, push the report commit, and verify the remote branch SHA and report/source paths on GitHub.
- Important: this is a source/report backup, not a database backup or server image. It does not preserve live customer data, Docker volumes, runtime environment secrets, TLS private keys, or Android signing-key passwords. Those must be separately backed up securely if needed before wiping the server.
