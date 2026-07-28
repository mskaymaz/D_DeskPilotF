#include "tts_service.h"
#include <QDebug>

#ifdef Q_OS_WIN
#include <windows.h>
#include <sapi.h>
#endif

namespace DeskPilot {

TtsService::TtsService(QObject *parent)
    : QObject(parent)
{
    initializeVoice();
}

TtsService::~TtsService()
{
#ifdef Q_OS_WIN
    if (m_voiceContext) {
        auto *voice = static_cast<ISpVoice*>(m_voiceContext);
        voice->Release();
    }
    CoUninitialize();
#endif
}

void TtsService::initializeVoice()
{
#ifdef Q_OS_WIN
    HRESULT hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if (FAILED(hr) && hr != RPC_E_CHANGED_MODE) {
        qWarning() << "DeskPilotC TtsService: CoInitializeEx failed.";
        return;
    }

    ISpVoice *voice = nullptr;
    if (FAILED(CoCreateInstance(CLSID_SpVoice, nullptr, CLSCTX_ALL, IID_ISpVoice, (void **)&voice))) {
        qWarning() << "DeskPilotC TtsService: Failed to create ISpVoice.";
        return;
    }
    m_voiceContext = voice;
    
    // Apply voice filter based on gender
    setUseFemaleVoice(m_useFemaleVoice);
#endif
}

void TtsService::setUseFemaleVoice(bool female)
{
    m_useFemaleVoice = female;
        
#ifdef Q_OS_WIN
    if (!m_voiceContext) return;
    auto *voice = static_cast<ISpVoice*>(m_voiceContext);
    
    ISpObjectTokenCategory *pCategory = nullptr;
    if (SUCCEEDED(CoCreateInstance(CLSID_SpObjectTokenCategory, nullptr, CLSCTX_ALL, IID_ISpObjectTokenCategory, (void**)&pCategory))) {
        if (SUCCEEDED(pCategory->SetId(SPCAT_VOICES, false))) {
            IEnumSpObjectTokens *pEnum = nullptr;
            const wchar_t* req = m_useFemaleVoice ? L"Gender=Female" : L"Gender=Male";
            if (SUCCEEDED(pCategory->EnumTokens(req, nullptr, &pEnum))) {
                ISpObjectToken *pToken = nullptr;
                if (SUCCEEDED(pEnum->Next(1, &pToken, nullptr)) && pToken != nullptr) {
                    voice->SetVoice(pToken);
                    pToken->Release();
                }
                pEnum->Release();
            }
        }
        pCategory->Release();
    }
#endif
    emit voiceChanged();
}

void TtsService::speak(const QString &text)
{
#ifdef Q_OS_WIN
    if (!m_voiceContext) return;
    auto *voice = static_cast<ISpVoice*>(m_voiceContext);
    
    // SPF_ASYNC = speak asynchronously. SPF_PURGEBEFORESPEAK = purge any pending speech.
    voice->Speak(reinterpret_cast<const wchar_t *>(text.utf16()), SPF_ASYNC | SPF_PURGEBEFORESPEAK, nullptr);
#endif
}

void TtsService::stop()
{
#ifdef Q_OS_WIN
    if (!m_voiceContext) return;
    auto *voice = static_cast<ISpVoice*>(m_voiceContext);
    
    voice->Speak(L"", SPF_ASYNC | SPF_PURGEBEFORESPEAK, nullptr);
#endif
}

} // namespace DeskPilot
